-- =====================================================
-- Sabo Arena - Complete PostgreSQL Schema Migration
-- From Firebase Firestore to Supabase PostgreSQL
-- =====================================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create custom types
CREATE TYPE user_skill_level AS ENUM ('beginner', 'intermediate', 'advanced', 'pro');
CREATE TYPE user_gender AS ENUM ('male', 'female', 'other');
CREATE TYPE account_status AS ENUM ('active', 'inactive', 'suspended', 'banned');
CREATE TYPE club_member_role AS ENUM ('owner', 'admin', 'moderator', 'member');
CREATE TYPE member_status AS ENUM ('active', 'inactive', 'banned', 'pending');
CREATE TYPE tournament_status AS ENUM ('upcoming', 'registration_open', 'registration_closed', 'in_progress', 'completed', 'cancelled');
CREATE TYPE match_status AS ENUM ('scheduled', 'in_progress', 'completed', 'cancelled', 'disputed');
CREATE TYPE message_type AS ENUM ('text', 'image', 'file', 'system');
CREATE TYPE tournament_type AS ENUM ('single_elimination', 'double_elimination', 'round_robin', 'swiss');
CREATE TYPE game_type AS ENUM ('8_ball', '9_ball', '10_ball', 'straight_pool', 'bank_pool');

-- =====================================================
-- 1. USERS TABLE
-- =====================================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    auth_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255),
    display_name VARCHAR(100),
    username VARCHAR(50) UNIQUE,
    photo_url TEXT,
    phone_number VARCHAR(20),
    location VARCHAR(255),
    birth_date DATE,
    gender user_gender,
    
    -- Game Statistics
    elo_rating INTEGER DEFAULT 1000,
    overall_ranking INTEGER,
    total_matches INTEGER DEFAULT 0,
    wins INTEGER DEFAULT 0,
    losses INTEGER DEFAULT 0,
    draws INTEGER DEFAULT 0,
    win_rate DECIMAL(5,2) DEFAULT 0.00,
    average_match_duration INTEGER DEFAULT 0, -- in minutes
    favorite_game_type game_type,
    skill_level user_skill_level DEFAULT 'beginner',
    
    -- Activity & Status
    is_online BOOLEAN DEFAULT false,
    last_active TIMESTAMP WITH TIME ZONE DEFAULT now(),
    account_status account_status DEFAULT 'active',
    is_verified BOOLEAN DEFAULT false,
    is_banned BOOLEAN DEFAULT false,
    ban_reason TEXT,
    
    -- Preferences (JSONB for flexibility)
    preferred_language VARCHAR(10) DEFAULT 'en',
    notification_settings JSONB DEFAULT '{"push_notifications": true, "email_notifications": true, "match_reminders": true}',
    privacy_settings JSONB DEFAULT '{"show_online_status": true, "show_location": false, "show_stats": true}',
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- =====================================================
-- 2. CLUBS TABLE
-- =====================================================
CREATE TABLE clubs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    logo_url TEXT,
    cover_image_url TEXT,
    location VARCHAR(255),
    address TEXT,
    phone_number VARCHAR(20),
    email VARCHAR(255),
    website VARCHAR(255),
    
    -- Club Info
    established_date DATE,
    club_type VARCHAR(50),
    membership_fee DECIMAL(10,2),
    max_members INTEGER,
    current_members INTEGER DEFAULT 0,
    
    -- Settings
    is_public BOOLEAN DEFAULT true,
    requires_approval BOOLEAN DEFAULT false,
    club_rules TEXT,
    operating_hours JSONB DEFAULT '{}',
    
    -- Owner
    owner_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- =====================================================
-- 3. CLUB MEMBERS TABLE
-- =====================================================
CREATE TABLE club_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    role club_member_role DEFAULT 'member',
    status member_status DEFAULT 'active',
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    
    -- Constraints
    UNIQUE(club_id, user_id)
);

-- =====================================================
-- 4. TOURNAMENTS TABLE
-- =====================================================
CREATE TABLE tournaments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    banner_image_url TEXT,
    
    -- Tournament Info
    tournament_type tournament_type DEFAULT 'single_elimination',
    game_type game_type DEFAULT '8_ball',
    max_participants INTEGER DEFAULT 16,
    current_participants INTEGER DEFAULT 0,
    entry_fee DECIMAL(10,2) DEFAULT 0.00,
    prize_pool DECIMAL(10,2) DEFAULT 0.00,
    
    -- Schedule
    registration_start TIMESTAMP WITH TIME ZONE,
    registration_end TIMESTAMP WITH TIME ZONE,
    tournament_start TIMESTAMP WITH TIME ZONE,
    tournament_end TIMESTAMP WITH TIME ZONE,
    
    -- Status
    status tournament_status DEFAULT 'upcoming',
    
    -- Organization
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    organizer_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    -- Settings
    tournament_rules TEXT,
    bracket_settings JSONB DEFAULT '{}',
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- =====================================================
-- 5. TOURNAMENT PARTICIPANTS TABLE
-- =====================================================
CREATE TABLE tournament_participants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tournament_id UUID REFERENCES tournaments(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    registration_date TIMESTAMP WITH TIME ZONE DEFAULT now(),
    seed_number INTEGER,
    status VARCHAR(20) DEFAULT 'registered' CHECK (status IN ('registered', 'checked_in', 'playing', 'eliminated', 'winner')),
    
    -- Constraints
    UNIQUE(tournament_id, user_id)
);

-- =====================================================
-- 6. MATCHES TABLE
-- =====================================================
CREATE TABLE matches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Participants
    player1_id UUID REFERENCES users(id) ON DELETE CASCADE,
    player2_id UUID REFERENCES users(id) ON DELETE CASCADE,
    winner_id UUID REFERENCES users(id),
    
    -- Match Info
    match_type VARCHAR(50) DEFAULT 'casual',
    game_type game_type DEFAULT '8_ball',
    tournament_id UUID REFERENCES tournaments(id) ON DELETE SET NULL,
    club_id UUID REFERENCES clubs(id) ON DELETE SET NULL,
    round_number INTEGER,
    bracket_position VARCHAR(50),
    
    -- Scores
    player1_score INTEGER DEFAULT 0,
    player2_score INTEGER DEFAULT 0,
    best_of INTEGER DEFAULT 1,
    
    -- Timing
    scheduled_time TIMESTAMP WITH TIME ZONE,
    start_time TIMESTAMP WITH TIME ZONE,
    end_time TIMESTAMP WITH TIME ZONE,
    duration_minutes INTEGER,
    
    -- Status
    status match_status DEFAULT 'scheduled',
    
    -- Additional Info
    match_details JSONB DEFAULT '{}',
    notes TEXT,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- =====================================================
-- 7. PLAYER STATISTICS TABLE
-- =====================================================
CREATE TABLE player_statistics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    -- Period
    period_type VARCHAR(20) DEFAULT 'all_time' CHECK (period_type IN ('daily', 'weekly', 'monthly', 'yearly', 'all_time')),
    period_start DATE,
    period_end DATE,
    
    -- Game Statistics
    games_played INTEGER DEFAULT 0,
    games_won INTEGER DEFAULT 0,
    games_lost INTEGER DEFAULT 0,
    games_drawn INTEGER DEFAULT 0,
    win_percentage DECIMAL(5,2) DEFAULT 0.00,
    
    -- ELO Statistics
    elo_rating INTEGER DEFAULT 1000,
    elo_peak INTEGER DEFAULT 1000,
    elo_change INTEGER DEFAULT 0,
    
    -- Performance Metrics
    average_game_duration INTEGER DEFAULT 0,
    longest_win_streak INTEGER DEFAULT 0,
    current_win_streak INTEGER DEFAULT 0,
    longest_loss_streak INTEGER DEFAULT 0,
    current_loss_streak INTEGER DEFAULT 0,
    
    -- Tournament Stats
    tournaments_participated INTEGER DEFAULT 0,
    tournaments_won INTEGER DEFAULT 0,
    tournaments_top3 INTEGER DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    
    -- Constraints
    UNIQUE(user_id, period_type, period_start)
);

-- =====================================================
-- 8. LEADERBOARDS TABLE
-- =====================================================
CREATE TABLE leaderboards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Leaderboard Info
    name VARCHAR(255) NOT NULL,
    description TEXT,
    leaderboard_type VARCHAR(50) DEFAULT 'elo' CHECK (leaderboard_type IN ('elo', 'wins', 'tournaments', 'win_rate')),
    period_type VARCHAR(20) DEFAULT 'all_time' CHECK (period_type IN ('daily', 'weekly', 'monthly', 'yearly', 'all_time')),
    
    -- Scope
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE, -- NULL for global leaderboards
    game_type game_type,
    
    -- Settings
    max_entries INTEGER DEFAULT 100,
    update_frequency VARCHAR(20) DEFAULT 'real_time',
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- =====================================================
-- 9. LEADERBOARD ENTRIES TABLE
-- =====================================================
CREATE TABLE leaderboard_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    leaderboard_id UUID REFERENCES leaderboards(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    -- Ranking
    rank INTEGER NOT NULL,
    score DECIMAL(10,2) NOT NULL,
    previous_rank INTEGER,
    rank_change INTEGER DEFAULT 0,
    
    -- Period
    period_start DATE,
    period_end DATE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    
    -- Constraints
    UNIQUE(leaderboard_id, user_id, period_start)
);

-- =====================================================
-- 10. NOTIFICATIONS TABLE
-- =====================================================
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    -- Content
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    
    -- Status
    is_read BOOLEAN DEFAULT false,
    is_sent BOOLEAN DEFAULT false,
    
    -- Data
    data JSONB DEFAULT '{}',
    action_url TEXT,
    
    -- Timestamps
    scheduled_time TIMESTAMP WITH TIME ZONE DEFAULT now(),
    sent_time TIMESTAMP WITH TIME ZONE,
    read_time TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- =====================================================
-- 11. CHAT MESSAGES TABLE
-- =====================================================
CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Message Info
    content TEXT NOT NULL,
    message_type message_type DEFAULT 'text',
    
    -- Participants
    sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    -- Context
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    tournament_id UUID REFERENCES tournaments(id) ON DELETE CASCADE,
    match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
    
    -- Status
    is_edited BOOLEAN DEFAULT false,
    is_deleted BOOLEAN DEFAULT false,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    
    -- Constraints: Message must belong to exactly one context
    CHECK (
        (club_id IS NOT NULL AND tournament_id IS NULL AND match_id IS NULL) OR
        (club_id IS NULL AND tournament_id IS NOT NULL AND match_id IS NULL) OR
        (club_id IS NULL AND tournament_id IS NULL AND match_id IS NOT NULL)
    )
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Users indexes
CREATE INDEX idx_users_auth_id ON users(auth_id);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_elo_rating ON users(elo_rating);
CREATE INDEX idx_users_overall_ranking ON users(overall_ranking);

-- Clubs indexes
CREATE INDEX idx_clubs_owner_id ON clubs(owner_id);
CREATE INDEX idx_clubs_is_public ON clubs(is_public);
CREATE INDEX idx_clubs_location ON clubs(location);

-- Club members indexes
CREATE INDEX idx_club_members_club_id ON club_members(club_id);
CREATE INDEX idx_club_members_user_id ON club_members(user_id);
CREATE INDEX idx_club_members_role ON club_members(role);

-- Tournaments indexes
CREATE INDEX idx_tournaments_club_id ON tournaments(club_id);
CREATE INDEX idx_tournaments_organizer_id ON tournaments(organizer_id);
CREATE INDEX idx_tournaments_status ON tournaments(status);
CREATE INDEX idx_tournaments_start_time ON tournaments(tournament_start);

-- Tournament participants indexes
CREATE INDEX idx_tournament_participants_tournament_id ON tournament_participants(tournament_id);
CREATE INDEX idx_tournament_participants_user_id ON tournament_participants(user_id);

-- Matches indexes
CREATE INDEX idx_matches_player1_id ON matches(player1_id);
CREATE INDEX idx_matches_player2_id ON matches(player2_id);
CREATE INDEX idx_matches_tournament_id ON matches(tournament_id);
CREATE INDEX idx_matches_club_id ON matches(club_id);
CREATE INDEX idx_matches_status ON matches(status);
CREATE INDEX idx_matches_scheduled_time ON matches(scheduled_time);

-- Player statistics indexes
CREATE INDEX idx_player_statistics_user_id ON player_statistics(user_id);
CREATE INDEX idx_player_statistics_period ON player_statistics(period_type, period_start);

-- Leaderboards indexes
CREATE INDEX idx_leaderboards_club_id ON leaderboards(club_id);
CREATE INDEX idx_leaderboards_type_period ON leaderboards(leaderboard_type, period_type);

-- Leaderboard entries indexes
CREATE INDEX idx_leaderboard_entries_leaderboard_id ON leaderboard_entries(leaderboard_id);
CREATE INDEX idx_leaderboard_entries_user_id ON leaderboard_entries(user_id);
CREATE INDEX idx_leaderboard_entries_rank ON leaderboard_entries(rank);

-- Notifications indexes
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);

-- Chat messages indexes
CREATE INDEX idx_chat_messages_sender_id ON chat_messages(sender_id);
CREATE INDEX idx_chat_messages_club_id ON chat_messages(club_id);
CREATE INDEX idx_chat_messages_tournament_id ON chat_messages(tournament_id);
CREATE INDEX idx_chat_messages_match_id ON chat_messages(match_id);
CREATE INDEX idx_chat_messages_created_at ON chat_messages(created_at);

-- =====================================================
-- TRIGGERS FOR AUTOMATIC UPDATES
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add updated_at triggers to all tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_clubs_updated_at BEFORE UPDATE ON clubs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tournaments_updated_at BEFORE UPDATE ON tournaments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_matches_updated_at BEFORE UPDATE ON matches
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_player_statistics_updated_at BEFORE UPDATE ON player_statistics
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_leaderboards_updated_at BEFORE UPDATE ON leaderboards
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_leaderboard_entries_updated_at BEFORE UPDATE ON leaderboard_entries
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_chat_messages_updated_at BEFORE UPDATE ON chat_messages
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- FUNCTIONS FOR BUSINESS LOGIC
-- =====================================================

-- Function to update user statistics after match completion
CREATE OR REPLACE FUNCTION update_user_statistics_after_match()
RETURNS TRIGGER AS $$
BEGIN
    -- Only trigger when match is completed
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        -- Update player1 statistics
        UPDATE users SET
            total_matches = total_matches + 1,
            wins = CASE WHEN NEW.winner_id = NEW.player1_id THEN wins + 1 ELSE wins END,
            losses = CASE WHEN NEW.winner_id = NEW.player2_id THEN losses + 1 ELSE losses END,
            draws = CASE WHEN NEW.winner_id IS NULL THEN draws + 1 ELSE draws END,
            win_rate = CASE 
                WHEN total_matches + 1 > 0 THEN 
                    (CASE WHEN NEW.winner_id = NEW.player1_id THEN wins + 1 ELSE wins END) * 100.0 / (total_matches + 1)
                ELSE 0 
            END
        WHERE id = NEW.player1_id;

        -- Update player2 statistics
        UPDATE users SET
            total_matches = total_matches + 1,
            wins = CASE WHEN NEW.winner_id = NEW.player2_id THEN wins + 1 ELSE wins END,
            losses = CASE WHEN NEW.winner_id = NEW.player1_id THEN losses + 1 ELSE losses END,
            draws = CASE WHEN NEW.winner_id IS NULL THEN draws + 1 ELSE draws END,
            win_rate = CASE 
                WHEN total_matches + 1 > 0 THEN 
                    (CASE WHEN NEW.winner_id = NEW.player2_id THEN wins + 1 ELSE wins END) * 100.0 / (total_matches + 1)
                ELSE 0 
            END
        WHERE id = NEW.player2_id;
    END IF;

    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for match completion
CREATE TRIGGER update_user_statistics_on_match_completion
    AFTER UPDATE ON matches
    FOR EACH ROW EXECUTE FUNCTION update_user_statistics_after_match();

-- Function to update club member count
CREATE OR REPLACE FUNCTION update_club_member_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE clubs SET current_members = current_members + 1 WHERE id = NEW.club_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE clubs SET current_members = current_members - 1 WHERE id = OLD.club_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ language 'plpgsql';

-- Create triggers for club member count
CREATE TRIGGER update_club_member_count_on_insert
    AFTER INSERT ON club_members
    FOR EACH ROW EXECUTE FUNCTION update_club_member_count();

CREATE TRIGGER update_club_member_count_on_delete
    AFTER DELETE ON club_members
    FOR EACH ROW EXECUTE FUNCTION update_club_member_count();

-- Function to update tournament participant count
CREATE OR REPLACE FUNCTION update_tournament_participant_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE tournaments SET current_participants = current_participants + 1 WHERE id = NEW.tournament_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE tournaments SET current_participants = current_participants - 1 WHERE id = OLD.tournament_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ language 'plpgsql';

-- Create triggers for tournament participant count
CREATE TRIGGER update_tournament_participant_count_on_insert
    AFTER INSERT ON tournament_participants
    FOR EACH ROW EXECUTE FUNCTION update_tournament_participant_count();

CREATE TRIGGER update_tournament_participant_count_on_delete
    AFTER DELETE ON tournament_participants
    FOR EACH ROW EXECUTE FUNCTION update_tournament_participant_count();

-- =====================================================
-- SAMPLE DATA FOR TESTING
-- =====================================================

-- This will be populated by a separate script
-- See: supabase/sample_data.sql