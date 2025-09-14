-- Complete Additional Tables for Sabo Arena
-- Creates 10 additional tables for complete billiards management system
-- Execute this in Supabase SQL Editor

-- 1. User relationships - Follow/following system
CREATE TABLE IF NOT EXISTS user_relationships (
    relationship_id VARCHAR(255) PRIMARY KEY DEFAULT gen_random_uuid()::text,
    follower_uid VARCHAR(255) NOT NULL,
    following_uid VARCHAR(255) NOT NULL,
    status VARCHAR(50) DEFAULT 'Active',
    created_time TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(follower_uid, following_uid)
);

-- 2. Rankings - Ranking system
CREATE TABLE IF NOT EXISTS rankings (
    ranking_id VARCHAR(255) PRIMARY KEY DEFAULT gen_random_uuid()::text,
    rank_type VARCHAR(100) NOT NULL,
    position INTEGER NOT NULL,
    score INTEGER NOT NULL,
    period VARCHAR(50) NOT NULL,
    updated_time TIMESTAMPTZ DEFAULT NOW(),
    club_id VARCHAR(255),
    ranking_criteria VARCHAR(255),
    uid VARCHAR(255) NOT NULL
);

-- 3. User settings - User preferences
CREATE TABLE IF NOT EXISTS user_settings (
    notification_match BOOLEAN DEFAULT TRUE,
    notification_tournament BOOLEAN DEFAULT TRUE,
    privacy_profile VARCHAR(50) DEFAULT 'Public',
    language VARCHAR(10) DEFAULT 'vi',
    theme VARCHAR(20) DEFAULT 'Light',
    updated_time TIMESTAMPTZ DEFAULT NOW(),
    uid VARCHAR(255) PRIMARY KEY
);

-- 4. Messages - Chat system
CREATE TABLE IF NOT EXISTS messages (
    message_id VARCHAR(255) PRIMARY KEY DEFAULT gen_random_uuid()::text,
    conversation_id VARCHAR(255) NOT NULL,
    sender_uid VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    message_type VARCHAR(50) DEFAULT 'Text',
    is_read BOOLEAN DEFAULT FALSE,
    created_time TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Conversations - Chat conversations
CREATE TABLE IF NOT EXISTS conversations (
    conversation_id VARCHAR(255) PRIMARY KEY DEFAULT gen_random_uuid()::text,
    participant1_uid VARCHAR(255) NOT NULL,
    participant2_uid VARCHAR(255) NOT NULL,
    last_message TEXT,
    last_message_time TIMESTAMPTZ,
    created_time TIMESTAMPTZ DEFAULT NOW(),
    updated_time TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(participant1_uid, participant2_uid)
);

-- 6. Club reviews - Club rating system
CREATE TABLE IF NOT EXISTS club_reviews (
    review_id VARCHAR(255) PRIMARY KEY DEFAULT gen_random_uuid()::text,
    club_id VARCHAR(255) NOT NULL,
    reviewer_uid VARCHAR(255) NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_time TIMESTAMPTZ DEFAULT NOW(),
    status VARCHAR(50) DEFAULT 'Active',
    UNIQUE(club_id, reviewer_uid)
);

-- 7. Achievements - Achievement definitions
CREATE TABLE IF NOT EXISTS achievements (
    achievement_id VARCHAR(255) PRIMARY KEY DEFAULT gen_random_uuid()::text,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    badge_icon TEXT,
    requirement_type VARCHAR(100) NOT NULL,
    requirement_value INTEGER NOT NULL,
    spa_reward INTEGER DEFAULT 0,
    created_time TIMESTAMPTZ DEFAULT NOW()
);

-- 8. User achievements - User achievement tracking
CREATE TABLE IF NOT EXISTS user_achievements (
    user_achievement_id VARCHAR(255) PRIMARY KEY DEFAULT gen_random_uuid()::text,
    achievement_id VARCHAR(255) NOT NULL,
    progress INTEGER DEFAULT 0,
    is_completed BOOLEAN DEFAULT FALSE,
    completed_time TIMESTAMPTZ,
    created_time TIMESTAMPTZ DEFAULT NOW(),
    uid VARCHAR(255) NOT NULL,
    UNIQUE(achievement_id, uid)
);

-- 9. Match ratings - Match rating system
CREATE TABLE IF NOT EXISTS match_ratings (
    rating_id VARCHAR(255) PRIMARY KEY DEFAULT gen_random_uuid()::text,
    match_id VARCHAR(255) NOT NULL,
    rater_uid VARCHAR(255) NOT NULL,
    rated_uid VARCHAR(255) NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    rating_type VARCHAR(50) DEFAULT 'Performance',
    created_time TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(match_id, rater_uid, rated_uid)
);

-- 10. Club staff - Club staff management
CREATE TABLE IF NOT EXISTS club_staff (
    staff_id VARCHAR(255) PRIMARY KEY DEFAULT gen_random_uuid()::text,
    club_id VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    can_confirm_matches BOOLEAN DEFAULT FALSE,
    created_time TIMESTAMPTZ DEFAULT NOW(),
    uid VARCHAR(255) NOT NULL,
    UNIQUE(club_id, uid)
);

-- Create performance indexes
CREATE INDEX IF NOT EXISTS idx_user_relationships_follower ON user_relationships(follower_uid);
CREATE INDEX IF NOT EXISTS idx_user_relationships_following ON user_relationships(following_uid);
CREATE INDEX IF NOT EXISTS idx_user_relationships_status ON user_relationships(status);

CREATE INDEX IF NOT EXISTS idx_rankings_uid ON rankings(uid);
CREATE INDEX IF NOT EXISTS idx_rankings_rank_type ON rankings(rank_type);
CREATE INDEX IF NOT EXISTS idx_rankings_position ON rankings(position);
CREATE INDEX IF NOT EXISTS idx_rankings_club_id ON rankings(club_id);

CREATE INDEX IF NOT EXISTS idx_messages_conversation ON messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_uid);
CREATE INDEX IF NOT EXISTS idx_messages_created_time ON messages(created_time);
CREATE INDEX IF NOT EXISTS idx_messages_is_read ON messages(is_read);

CREATE INDEX IF NOT EXISTS idx_conversations_participant1 ON conversations(participant1_uid);
CREATE INDEX IF NOT EXISTS idx_conversations_participant2 ON conversations(participant2_uid);
CREATE INDEX IF NOT EXISTS idx_conversations_last_message_time ON conversations(last_message_time);

CREATE INDEX IF NOT EXISTS idx_club_reviews_club_id ON club_reviews(club_id);
CREATE INDEX IF NOT EXISTS idx_club_reviews_reviewer ON club_reviews(reviewer_uid);
CREATE INDEX IF NOT EXISTS idx_club_reviews_rating ON club_reviews(rating);

CREATE INDEX IF NOT EXISTS idx_user_achievements_uid ON user_achievements(uid);
CREATE INDEX IF NOT EXISTS idx_user_achievements_achievement ON user_achievements(achievement_id);
CREATE INDEX IF NOT EXISTS idx_user_achievements_completed ON user_achievements(is_completed);

CREATE INDEX IF NOT EXISTS idx_match_ratings_match_id ON match_ratings(match_id);
CREATE INDEX IF NOT EXISTS idx_match_ratings_rater ON match_ratings(rater_uid);
CREATE INDEX IF NOT EXISTS idx_match_ratings_rated ON match_ratings(rated_uid);

CREATE INDEX IF NOT EXISTS idx_club_staff_club_id ON club_staff(club_id);
CREATE INDEX IF NOT EXISTS idx_club_staff_uid ON club_staff(uid);
CREATE INDEX IF NOT EXISTS idx_club_staff_role ON club_staff(role);

-- Enable Row Level Security
ALTER TABLE user_relationships ENABLE ROW LEVEL SECURITY;
ALTER TABLE rankings ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE club_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE match_ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE club_staff ENABLE ROW LEVEL SECURITY;

-- Basic RLS Policies
-- User relationships: users can manage their own relationships
CREATE POLICY IF NOT EXISTS policy_user_relationships_own ON user_relationships
    FOR ALL USING (auth.uid()::text IN (follower_uid, following_uid));

-- Rankings: public view
CREATE POLICY IF NOT EXISTS policy_rankings_view ON rankings
    FOR SELECT USING (true);

-- User settings: users can only access their own settings
CREATE POLICY IF NOT EXISTS policy_user_settings_own ON user_settings
    FOR ALL USING (auth.uid()::text = uid);

-- Messages: participants can view conversation messages
CREATE POLICY IF NOT EXISTS policy_messages_participants ON messages
    FOR ALL USING (
        conversation_id IN (
            SELECT conversation_id FROM conversations 
            WHERE auth.uid()::text IN (participant1_uid, participant2_uid)
        )
    );

-- Conversations: participants can view their conversations
CREATE POLICY IF NOT EXISTS policy_conversations_participants ON conversations
    FOR ALL USING (auth.uid()::text IN (participant1_uid, participant2_uid));

-- Club reviews: public view, users can manage their own reviews
CREATE POLICY IF NOT EXISTS policy_club_reviews_view ON club_reviews
    FOR SELECT USING (true);

-- Achievements: public view
CREATE POLICY IF NOT EXISTS policy_achievements_view ON achievements
    FOR SELECT USING (true);

-- User achievements: users can view their own achievements
CREATE POLICY IF NOT EXISTS policy_user_achievements_own ON user_achievements
    FOR ALL USING (auth.uid()::text = uid);

-- Match ratings: public view for completed matches
CREATE POLICY IF NOT EXISTS policy_match_ratings_view ON match_ratings
    FOR SELECT USING (true);

-- Club staff: staff can view, owners can manage
CREATE POLICY IF NOT EXISTS policy_club_staff_view ON club_staff
    FOR SELECT USING (true);

-- Success notification
SELECT 'All 10 additional tables created successfully!' as result;