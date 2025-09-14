-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- Secure access control for Sabo Arena
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE clubs ENABLE ROW LEVEL SECURITY;
ALTER TABLE club_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE tournaments ENABLE ROW LEVEL SECURITY;
ALTER TABLE tournament_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_statistics ENABLE ROW LEVEL SECURITY;
ALTER TABLE leaderboards ENABLE ROW LEVEL SECURITY;
ALTER TABLE leaderboard_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- USERS TABLE POLICIES
-- =====================================================

-- Anyone can view user profiles (public information)
CREATE POLICY "Users can view all profiles" ON users FOR SELECT USING (true);

-- Users can only update their own profile
CREATE POLICY "Users can update own profile" ON users 
FOR UPDATE USING (auth.uid() = auth_id);

-- Users can insert their own profile during registration
CREATE POLICY "Users can insert own profile" ON users 
FOR INSERT WITH CHECK (auth.uid() = auth_id);

-- Only admins can delete users (handled by auth.users cascade)
CREATE POLICY "Only system can delete users" ON users 
FOR DELETE USING (false);

-- =====================================================
-- CLUBS TABLE POLICIES
-- =====================================================

-- Anyone can view public clubs
CREATE POLICY "Anyone can view public clubs" ON clubs 
FOR SELECT USING (is_public = true);

-- Club members can view private clubs they belong to
CREATE POLICY "Club members can view private clubs" ON clubs 
FOR SELECT USING (
    NOT is_public AND id IN (
        SELECT club_id FROM club_members 
        WHERE user_id = (SELECT id FROM users WHERE auth_id = auth.uid())
        AND status = 'active'
    )
);

-- Only authenticated users can create clubs
CREATE POLICY "Authenticated users can create clubs" ON clubs 
FOR INSERT WITH CHECK (
    auth.uid() IS NOT NULL AND 
    owner_id = (SELECT id FROM users WHERE auth_id = auth.uid())
);

-- Club owners and admins can update their clubs
CREATE POLICY "Club owners and admins can update clubs" ON clubs 
FOR UPDATE USING (
    auth.uid() = (SELECT auth_id FROM users WHERE id = owner_id) OR
    (SELECT id FROM users WHERE auth_id = auth.uid()) IN (
        SELECT user_id FROM club_members 
        WHERE club_id = clubs.id 
        AND role IN ('owner', 'admin') 
        AND status = 'active'
    )
);

-- Only club owners can delete clubs
CREATE POLICY "Only club owners can delete clubs" ON clubs 
FOR DELETE USING (auth.uid() = (SELECT auth_id FROM users WHERE id = owner_id));

-- =====================================================
-- CLUB MEMBERS TABLE POLICIES
-- =====================================================

-- Club members can view membership of their clubs
CREATE POLICY "Club members can view club membership" ON club_members 
FOR SELECT USING (
    club_id IN (
        SELECT club_id FROM club_members cm 
        WHERE cm.user_id = (SELECT id FROM users WHERE auth_id = auth.uid())
        AND cm.status = 'active'
    )
);

-- Users can join public clubs or request to join private clubs
CREATE POLICY "Users can join clubs" ON club_members 
FOR INSERT WITH CHECK (
    auth.uid() IS NOT NULL AND 
    user_id = (SELECT id FROM users WHERE auth_id = auth.uid()) AND
    (
        -- Can join public clubs that don't require approval
        (SELECT is_public AND NOT requires_approval FROM clubs WHERE id = club_id) OR
        -- Can request to join any club (will be pending)
        status = 'pending'
    )
);

-- Club admins can update member status and roles
CREATE POLICY "Club admins can manage members" ON club_members 
FOR UPDATE USING (
    (SELECT id FROM users WHERE auth_id = auth.uid()) IN (
        SELECT user_id FROM club_members cm 
        WHERE cm.club_id = club_members.club_id 
        AND cm.role IN ('owner', 'admin') 
        AND cm.status = 'active'
    )
);

-- Users can leave clubs, admins can remove members
CREATE POLICY "Users can leave clubs or be removed by admins" ON club_members 
FOR DELETE USING (
    -- Users can leave clubs themselves
    user_id = (SELECT id FROM users WHERE auth_id = auth.uid()) OR
    -- Club admins can remove members
    (SELECT id FROM users WHERE auth_id = auth.uid()) IN (
        SELECT user_id FROM club_members cm 
        WHERE cm.club_id = club_members.club_id 
        AND cm.role IN ('owner', 'admin') 
        AND cm.status = 'active'
    )
);

-- =====================================================
-- TOURNAMENTS TABLE POLICIES
-- =====================================================

-- Anyone can view public tournaments
CREATE POLICY "Anyone can view tournaments" ON tournaments FOR SELECT USING (true);

-- Club members can create tournaments for their clubs
CREATE POLICY "Club members can create tournaments" ON tournaments 
FOR INSERT WITH CHECK (
    auth.uid() IS NOT NULL AND 
    organizer_id = (SELECT id FROM users WHERE auth_id = auth.uid()) AND
    (
        club_id IS NULL OR -- Global tournaments
        (SELECT id FROM users WHERE auth_id = auth.uid()) IN (
            SELECT user_id FROM club_members 
            WHERE club_id = tournaments.club_id 
            AND role IN ('owner', 'admin', 'moderator') 
            AND status = 'active'
        )
    )
);

-- Tournament organizers and club admins can update tournaments
CREATE POLICY "Tournament organizers can update tournaments" ON tournaments 
FOR UPDATE USING (
    organizer_id = (SELECT id FROM users WHERE auth_id = auth.uid()) OR
    (SELECT id FROM users WHERE auth_id = auth.uid()) IN (
        SELECT user_id FROM club_members 
        WHERE club_id = tournaments.club_id 
        AND role IN ('owner', 'admin') 
        AND status = 'active'
    )
);

-- Only tournament organizers and club owners can delete tournaments
CREATE POLICY "Tournament organizers can delete tournaments" ON tournaments 
FOR DELETE USING (
    organizer_id = (SELECT id FROM users WHERE auth_id = auth.uid()) OR
    (club_id IS NOT NULL AND auth.uid() = (
        SELECT auth_id FROM users WHERE id = (
            SELECT owner_id FROM clubs WHERE id = tournaments.club_id
        )
    ))
);

-- =====================================================
-- TOURNAMENT PARTICIPANTS TABLE POLICIES
-- =====================================================

-- Anyone can view tournament participants
CREATE POLICY "Anyone can view tournament participants" ON tournament_participants 
FOR SELECT USING (true);

-- Users can register themselves for tournaments
CREATE POLICY "Users can register for tournaments" ON tournament_participants 
FOR INSERT WITH CHECK (
    auth.uid() IS NOT NULL AND 
    user_id = (SELECT id FROM users WHERE auth_id = auth.uid())
);

-- Tournament organizers can update participant status
CREATE POLICY "Tournament organizers can manage participants" ON tournament_participants 
FOR UPDATE USING (
    (SELECT organizer_id FROM tournaments WHERE id = tournament_id) = 
    (SELECT id FROM users WHERE auth_id = auth.uid())
);

-- Users can withdraw, organizers can remove participants
CREATE POLICY "Users can withdraw from tournaments" ON tournament_participants 
FOR DELETE USING (
    user_id = (SELECT id FROM users WHERE auth_id = auth.uid()) OR
    (SELECT organizer_id FROM tournaments WHERE id = tournament_id) = 
    (SELECT id FROM users WHERE auth_id = auth.uid())
);

-- =====================================================
-- MATCHES TABLE POLICIES
-- =====================================================

-- Anyone can view match results
CREATE POLICY "Anyone can view matches" ON matches FOR SELECT USING (true);

-- Tournament organizers and club admins can create matches
CREATE POLICY "Organizers can create matches" ON matches 
FOR INSERT WITH CHECK (
    auth.uid() IS NOT NULL AND 
    (
        -- Tournament matches
        (tournament_id IS NOT NULL AND 
         (SELECT organizer_id FROM tournaments WHERE id = tournament_id) = 
         (SELECT id FROM users WHERE auth_id = auth.uid())) OR
        -- Club matches
        (club_id IS NOT NULL AND 
         (SELECT id FROM users WHERE auth_id = auth.uid()) IN (
            SELECT user_id FROM club_members 
            WHERE club_id = matches.club_id 
            AND role IN ('owner', 'admin', 'moderator') 
            AND status = 'active'
         )) OR
        -- Casual matches - players can create their own
        (tournament_id IS NULL AND club_id IS NULL AND 
         (player1_id = (SELECT id FROM users WHERE auth_id = auth.uid()) OR
          player2_id = (SELECT id FROM users WHERE auth_id = auth.uid())))
    )
);

-- Match participants and organizers can update matches
CREATE POLICY "Match participants can update matches" ON matches 
FOR UPDATE USING (
    -- Players involved in the match
    player1_id = (SELECT id FROM users WHERE auth_id = auth.uid()) OR
    player2_id = (SELECT id FROM users WHERE auth_id = auth.uid()) OR
    -- Tournament organizers
    (tournament_id IS NOT NULL AND 
     (SELECT organizer_id FROM tournaments WHERE id = tournament_id) = 
     (SELECT id FROM users WHERE auth_id = auth.uid())) OR
    -- Club admins
    (club_id IS NOT NULL AND 
     (SELECT id FROM users WHERE auth_id = auth.uid()) IN (
        SELECT user_id FROM club_members 
        WHERE club_id = matches.club_id 
        AND role IN ('owner', 'admin') 
        AND status = 'active'
     ))
);

-- Limited delete permissions for matches
CREATE POLICY "Limited match deletion" ON matches 
FOR DELETE USING (
    -- Only tournament organizers for tournament matches
    (tournament_id IS NOT NULL AND 
     (SELECT organizer_id FROM tournaments WHERE id = tournament_id) = 
     (SELECT id FROM users WHERE auth_id = auth.uid())) OR
    -- Club owners for club matches
    (club_id IS NOT NULL AND 
     auth.uid() = (SELECT auth_id FROM users WHERE id = (
        SELECT owner_id FROM clubs WHERE id = matches.club_id
     )))
);

-- =====================================================
-- PLAYER STATISTICS TABLE POLICIES
-- =====================================================

-- Anyone can view player statistics
CREATE POLICY "Anyone can view player statistics" ON player_statistics 
FOR SELECT USING (true);

-- Only system can insert/update statistics (via triggers)
CREATE POLICY "Only system can modify statistics" ON player_statistics 
FOR INSERT WITH CHECK (false);

CREATE POLICY "Only system can update statistics" ON player_statistics 
FOR UPDATE USING (false);

CREATE POLICY "Only system can delete statistics" ON player_statistics 
FOR DELETE USING (false);

-- =====================================================
-- LEADERBOARDS TABLE POLICIES
-- =====================================================

-- Anyone can view leaderboards
CREATE POLICY "Anyone can view leaderboards" ON leaderboards FOR SELECT USING (true);

-- Club admins can create club leaderboards
CREATE POLICY "Club admins can create leaderboards" ON leaderboards 
FOR INSERT WITH CHECK (
    auth.uid() IS NOT NULL AND 
    (
        club_id IS NULL OR -- Global leaderboards (admin only - handled separately)
        (SELECT id FROM users WHERE auth_id = auth.uid()) IN (
            SELECT user_id FROM club_members 
            WHERE club_id = leaderboards.club_id 
            AND role IN ('owner', 'admin') 
            AND status = 'active'
        )
    )
);

-- Club admins can update their leaderboards
CREATE POLICY "Club admins can update leaderboards" ON leaderboards 
FOR UPDATE USING (
    (SELECT id FROM users WHERE auth_id = auth.uid()) IN (
        SELECT user_id FROM club_members 
        WHERE club_id = leaderboards.club_id 
        AND role IN ('owner', 'admin') 
        AND status = 'active'
    )
);

-- Club owners can delete leaderboards
CREATE POLICY "Club owners can delete leaderboards" ON leaderboards 
FOR DELETE USING (
    club_id IS NOT NULL AND 
    auth.uid() = (SELECT auth_id FROM users WHERE id = (
        SELECT owner_id FROM clubs WHERE id = leaderboards.club_id
    ))
);

-- =====================================================
-- LEADERBOARD ENTRIES TABLE POLICIES
-- =====================================================

-- Anyone can view leaderboard entries
CREATE POLICY "Anyone can view leaderboard entries" ON leaderboard_entries 
FOR SELECT USING (true);

-- Only system can manage leaderboard entries
CREATE POLICY "Only system can modify leaderboard entries" ON leaderboard_entries 
FOR INSERT WITH CHECK (false);

CREATE POLICY "Only system can update leaderboard entries" ON leaderboard_entries 
FOR UPDATE USING (false);

CREATE POLICY "Only system can delete leaderboard entries" ON leaderboard_entries 
FOR DELETE USING (false);

-- =====================================================
-- NOTIFICATIONS TABLE POLICIES
-- =====================================================

-- Users can only view their own notifications
CREATE POLICY "Users can view own notifications" ON notifications 
FOR SELECT USING (user_id = (SELECT id FROM users WHERE auth_id = auth.uid()));

-- Only system can create notifications
CREATE POLICY "Only system can create notifications" ON notifications 
FOR INSERT WITH CHECK (false);

-- Users can mark their notifications as read
CREATE POLICY "Users can update own notifications" ON notifications 
FOR UPDATE USING (
    user_id = (SELECT id FROM users WHERE auth_id = auth.uid()) AND
    -- Only allow updating read status and read_time
    (OLD.title = NEW.title AND OLD.message = NEW.message)
);

-- Users can delete their notifications
CREATE POLICY "Users can delete own notifications" ON notifications 
FOR DELETE USING (user_id = (SELECT id FROM users WHERE auth_id = auth.uid()));

-- =====================================================
-- CHAT MESSAGES TABLE POLICIES
-- =====================================================

-- Users can view messages in their clubs/tournaments/matches
CREATE POLICY "Users can view relevant chat messages" ON chat_messages 
FOR SELECT USING (
    -- Club messages - must be club member
    (club_id IS NOT NULL AND 
     club_id IN (
        SELECT club_id FROM club_members 
        WHERE user_id = (SELECT id FROM users WHERE auth_id = auth.uid())
        AND status = 'active'
     )) OR
    -- Tournament messages - must be participant
    (tournament_id IS NOT NULL AND 
     tournament_id IN (
        SELECT tournament_id FROM tournament_participants 
        WHERE user_id = (SELECT id FROM users WHERE auth_id = auth.uid())
     )) OR
    -- Match messages - must be involved in match
    (match_id IS NOT NULL AND 
     match_id IN (
        SELECT id FROM matches 
        WHERE player1_id = (SELECT id FROM users WHERE auth_id = auth.uid())
        OR player2_id = (SELECT id FROM users WHERE auth_id = auth.uid())
     ))
);

-- Users can send messages in contexts they have access to
CREATE POLICY "Users can send chat messages" ON chat_messages 
FOR INSERT WITH CHECK (
    auth.uid() IS NOT NULL AND 
    sender_id = (SELECT id FROM users WHERE auth_id = auth.uid()) AND
    (
        -- Club messages - must be club member
        (club_id IS NOT NULL AND 
         club_id IN (
            SELECT club_id FROM club_members 
            WHERE user_id = (SELECT id FROM users WHERE auth_id = auth.uid())
            AND status = 'active'
         )) OR
        -- Tournament messages - must be participant
        (tournament_id IS NOT NULL AND 
         tournament_id IN (
            SELECT tournament_id FROM tournament_participants 
            WHERE user_id = (SELECT id FROM users WHERE auth_id = auth.uid())
         )) OR
        -- Match messages - must be involved in match
        (match_id IS NOT NULL AND 
         match_id IN (
            SELECT id FROM matches 
            WHERE player1_id = (SELECT id FROM users WHERE auth_id = auth.uid())
            OR player2_id = (SELECT id FROM users WHERE auth_id = auth.uid())
         ))
    )
);

-- Users can edit/delete their own messages
CREATE POLICY "Users can edit own messages" ON chat_messages 
FOR UPDATE USING (
    sender_id = (SELECT id FROM users WHERE auth_id = auth.uid())
);

CREATE POLICY "Users can delete own messages" ON chat_messages 
FOR DELETE USING (
    sender_id = (SELECT id FROM users WHERE auth_id = auth.uid()) OR
    -- Club admins can delete messages in their clubs
    (club_id IS NOT NULL AND 
     (SELECT id FROM users WHERE auth_id = auth.uid()) IN (
        SELECT user_id FROM club_members 
        WHERE club_id = chat_messages.club_id 
        AND role IN ('owner', 'admin') 
        AND status = 'active'
     ))
);

-- =====================================================
-- STORAGE BUCKET POLICIES
-- =====================================================

-- Note: These need to be set in the Supabase Storage interface

/*
-- Avatar bucket policy (public read, authenticated upload)
INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true);

CREATE POLICY "Avatar images are publicly accessible" ON storage.objects
FOR SELECT USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload their own avatar" ON storage.objects
FOR INSERT WITH CHECK (
    bucket_id = 'avatars' AND 
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = (SELECT id::text FROM users WHERE auth_id = auth.uid())
);

CREATE POLICY "Users can update their own avatar" ON storage.objects
FOR UPDATE USING (
    bucket_id = 'avatars' AND 
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = (SELECT id::text FROM users WHERE auth_id = auth.uid())
);

CREATE POLICY "Users can delete their own avatar" ON storage.objects
FOR DELETE USING (
    bucket_id = 'avatars' AND 
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = (SELECT id::text FROM users WHERE auth_id = auth.uid())
);
*/