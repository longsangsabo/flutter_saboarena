-- COMPLETE SABO ARENA DATABASE MIGRATION
-- Execute all tables at once for faster deployment
-- Description: Creates all 8 tables for billiards arena management system

BEGIN;

-- 1. USERS TABLE
CREATE TABLE users (
    uid VARCHAR(255) PRIMARY KEY,
    created_time TIMESTAMPTZ DEFAULT NOW(),
    email VARCHAR(255),
    email_verified BOOLEAN DEFAULT FALSE,
    display_name VARCHAR(255),
    full_name VARCHAR(255),
    phone_number VARCHAR(20),
    photo_url TEXT,
    username VARCHAR(100) UNIQUE,
    date_of_birth DATE,
    current_elo INTEGER DEFAULT 1000,
    current_spa INTEGER DEFAULT 0,
    total_matches INTEGER DEFAULT 0,
    total_wins INTEGER DEFAULT 0,
    total_losses INTEGER DEFAULT 0,
    win_rate DECIMAL(5,2) DEFAULT 0.00,
    highest_elo INTEGER DEFAULT 1000,
    tournaments_won INTEGER DEFAULT 0,
    tournaments_played INTEGER DEFAULT 0,
    total_earnings DECIMAL(10,2) DEFAULT 0.00,
    club_id VARCHAR(255),
    privacy_settings JSONB DEFAULT '{}',
    last_activity TIMESTAMPTZ DEFAULT NOW(),
    is_verified BOOLEAN DEFAULT FALSE
);

-- 2. CLUBS TABLE  
CREATE TABLE clubs (
    club_id VARCHAR(255) PRIMARY KEY,
    created_time TIMESTAMPTZ DEFAULT NOW(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    logo_url TEXT,
    cover_photo_url TEXT,
    address TEXT,
    city VARCHAR(100),
    phone_number VARCHAR(20),
    email VARCHAR(255),
    website_url TEXT,
    created_by VARCHAR(255),
    owner VARCHAR(255),
    member_count INTEGER DEFAULT 0,
    total_tournaments INTEGER DEFAULT 0,
    is_verified BOOLEAN DEFAULT FALSE,
    rating DECIMAL(3,2) DEFAULT 0.00,
    total_ratings INTEGER DEFAULT 0,
    tags TEXT[],
    amenities JSONB DEFAULT '{}',
    operating_hours JSONB DEFAULT '{}'
);

-- 3. MATCHES TABLE
CREATE TABLE matches (
    match_id VARCHAR(255) PRIMARY KEY,
    created_time TIMESTAMPTZ DEFAULT NOW(),
    player1_uid VARCHAR(255),
    player2_uid VARCHAR(255),
    club_id VARCHAR(255),
    match_type VARCHAR(50) DEFAULT 'Casual',
    game_mode VARCHAR(50) DEFAULT '8-Ball',
    status VARCHAR(50) DEFAULT 'Scheduled',
    scheduled_time TIMESTAMPTZ,
    actual_start_time TIMESTAMPTZ,
    actual_end_time TIMESTAMPTZ,
    player1_score INTEGER DEFAULT 0,
    player2_score INTEGER DEFAULT 0,
    winner_uid VARCHAR(255),
    match_duration INTEGER,
    player1_elo_before INTEGER,
    player1_elo_after INTEGER,
    player2_elo_before INTEGER,
    player2_elo_after INTEGER,
    spa_points_awarded INTEGER DEFAULT 0,
    is_confirmed_by_club BOOLEAN DEFAULT FALSE,
    confirmed_by VARCHAR(255),
    confirmation_time TIMESTAMPTZ,
    match_data JSONB DEFAULT '{}'
);

-- 4. TOURNAMENTS TABLE
CREATE TABLE tournaments (
    tournament_id VARCHAR(255) PRIMARY KEY,
    created_time TIMESTAMPTZ DEFAULT NOW(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    club_id VARCHAR(255),
    created_by VARCHAR(255),
    tournament_type VARCHAR(50) DEFAULT 'Single Elimination',
    game_mode VARCHAR(50) DEFAULT '8-Ball',
    status VARCHAR(50) DEFAULT 'Registration',
    registration_start TIMESTAMPTZ,
    registration_end TIMESTAMPTZ,
    tournament_start TIMESTAMPTZ,
    tournament_end TIMESTAMPTZ,
    max_participants INTEGER DEFAULT 32,
    current_participants INTEGER DEFAULT 0,
    entry_fee DECIMAL(10,2) DEFAULT 0.00,
    prize_pool DECIMAL(10,2) DEFAULT 0.00,
    winner_uid VARCHAR(255),
    min_elo INTEGER,
    max_elo INTEGER,
    tournament_data JSONB DEFAULT '{}'
);

-- 5. MATCH_REQUESTS TABLE
CREATE TABLE match_requests (
    request_id VARCHAR(255) PRIMARY KEY,
    created_time TIMESTAMPTZ DEFAULT NOW(),
    requester_uid VARCHAR(255),
    target_uid VARCHAR(255),
    club_id VARCHAR(255),
    request_type VARCHAR(50) DEFAULT 'Direct',
    game_mode VARCHAR(50) DEFAULT '8-Ball',
    status VARCHAR(50) DEFAULT 'Pending',
    message TEXT,
    suggested_time TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    response_time TIMESTAMPTZ,
    created_match_id VARCHAR(255),
    stake_amount DECIMAL(10,2) DEFAULT 0.00,
    min_elo INTEGER,
    max_elo INTEGER,
    auto_accept BOOLEAN DEFAULT FALSE,
    request_data JSONB DEFAULT '{}'
);

-- 6. NOTIFICATIONS TABLE
CREATE TABLE notifications (
    notification_id VARCHAR(255) PRIMARY KEY,
    created_time TIMESTAMPTZ DEFAULT NOW(),
    recipient_uid VARCHAR(255),
    notification_type VARCHAR(100),
    title VARCHAR(255),
    message TEXT,
    data JSONB DEFAULT '{}',
    is_read BOOLEAN DEFAULT FALSE,
    read_time TIMESTAMPTZ,
    is_clicked BOOLEAN DEFAULT FALSE,
    clicked_time TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    priority VARCHAR(20) DEFAULT 'Normal',
    source_id VARCHAR(255)
);

-- 7. TOURNAMENT_PARTICIPANTS TABLE
CREATE TABLE tournament_participants (
    participant_id VARCHAR(255) PRIMARY KEY,
    created_time TIMESTAMPTZ DEFAULT NOW(),
    tournament_id VARCHAR(255),
    uid VARCHAR(255),
    registration_time TIMESTAMPTZ DEFAULT NOW(),
    status VARCHAR(50) DEFAULT 'Registered',
    bracket_position INTEGER,
    seed_number INTEGER,
    current_round INTEGER DEFAULT 1,
    wins INTEGER DEFAULT 0,
    losses INTEGER DEFAULT 0,
    is_eliminated BOOLEAN DEFAULT FALSE,
    elimination_round INTEGER,
    final_ranking INTEGER,
    prize_amount DECIMAL(10,2) DEFAULT 0.00,
    payment_status VARCHAR(50) DEFAULT 'Pending',
    participant_data JSONB DEFAULT '{}'
);

-- 8. TRANSACTIONS TABLE
CREATE TABLE transactions (
    transaction_id VARCHAR(255) PRIMARY KEY,
    transaction_type VARCHAR(100),
    elo_change INTEGER DEFAULT 0,
    spa_change INTEGER DEFAULT 0,
    old_elo INTEGER,
    new_elo INTEGER,
    old_spa INTEGER,
    new_spa INTEGER,
    source_type VARCHAR(100),
    source_id VARCHAR(255),
    description TEXT,
    created_time TIMESTAMPTZ DEFAULT NOW(),
    processed_time TIMESTAMPTZ,
    status VARCHAR(50) DEFAULT 'Pending',
    requires_confirmation BOOLEAN DEFAULT FALSE,
    confirmed_by VARCHAR(255),
    uid VARCHAR(255)
);

-- 9. CLUB_MEMBERS TABLE
CREATE TABLE club_members (
    member_id VARCHAR(255) PRIMARY KEY,
    club_id VARCHAR(255),
    uid VARCHAR(255),
    role VARCHAR(50) DEFAULT 'Member',
    joined_time TIMESTAMPTZ DEFAULT NOW(),
    status VARCHAR(50) DEFAULT 'Active',
    UNIQUE(club_id, uid)
);

-- CREATE ALL INDEXES
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_current_elo ON users(current_elo);
CREATE INDEX idx_users_club_id ON users(club_id);

CREATE INDEX idx_clubs_name ON clubs(name);
CREATE INDEX idx_clubs_city ON clubs(city);
CREATE INDEX idx_clubs_owner ON clubs(owner);
CREATE INDEX idx_clubs_created_by ON clubs(created_by);

CREATE INDEX idx_matches_player1 ON matches(player1_uid);
CREATE INDEX idx_matches_player2 ON matches(player2_uid);
CREATE INDEX idx_matches_club_id ON matches(club_id);
CREATE INDEX idx_matches_status ON matches(status);
CREATE INDEX idx_matches_scheduled_time ON matches(scheduled_time);

CREATE INDEX idx_tournaments_club_id ON tournaments(club_id);
CREATE INDEX idx_tournaments_created_by ON tournaments(created_by);
CREATE INDEX idx_tournaments_status ON tournaments(status);

CREATE INDEX idx_match_requests_requester ON match_requests(requester_uid);
CREATE INDEX idx_match_requests_target ON match_requests(target_uid);
CREATE INDEX idx_match_requests_status ON match_requests(status);

CREATE INDEX idx_notifications_recipient ON notifications(recipient_uid);
CREATE INDEX idx_notifications_type ON notifications(notification_type);
CREATE INDEX idx_notifications_read ON notifications(is_read);

CREATE INDEX idx_tournament_participants_tournament ON tournament_participants(tournament_id);
CREATE INDEX idx_tournament_participants_uid ON tournament_participants(uid);
CREATE INDEX idx_tournament_participants_status ON tournament_participants(status);

CREATE INDEX idx_transactions_uid ON transactions(uid);
CREATE INDEX idx_transactions_type ON transactions(transaction_type);
CREATE INDEX idx_transactions_status ON transactions(status);

CREATE INDEX idx_club_members_club_id ON club_members(club_id);
CREATE INDEX idx_club_members_uid ON club_members(uid);

-- ENABLE RLS ON ALL TABLES
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE clubs ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE tournaments ENABLE ROW LEVEL SECURITY;
ALTER TABLE match_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE tournament_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE club_members ENABLE ROW LEVEL SECURITY;

-- BASIC RLS POLICIES
CREATE POLICY policy_users_own ON users FOR ALL USING (auth.uid()::text = uid);
CREATE POLICY policy_clubs_view ON clubs FOR SELECT USING (true);
CREATE POLICY policy_matches_participants ON matches FOR ALL USING (auth.uid()::text IN (player1_uid, player2_uid));
CREATE POLICY policy_tournaments_view ON tournaments FOR SELECT USING (true);
CREATE POLICY policy_match_requests_involved ON match_requests FOR ALL USING (auth.uid()::text IN (requester_uid, target_uid));
CREATE POLICY policy_notifications_own ON notifications FOR ALL USING (auth.uid()::text = recipient_uid);
CREATE POLICY policy_tournament_participants_own ON tournament_participants FOR ALL USING (auth.uid()::text = uid);
CREATE POLICY policy_transactions_own ON transactions FOR SELECT USING (auth.uid()::text = uid);
CREATE POLICY policy_club_members_view ON club_members FOR SELECT USING (auth.uid()::text = uid OR club_id IN (SELECT club_id FROM club_members WHERE uid = auth.uid()::text));

COMMIT;

-- SUCCESS MESSAGE
DO $$
BEGIN
    RAISE NOTICE '🎉 SABO ARENA DATABASE MIGRATION COMPLETED!';
    RAISE NOTICE '✅ Created 9 tables:';
    RAISE NOTICE '   1. users (24 columns) - User profiles & stats';
    RAISE NOTICE '   2. clubs (20 columns) - Billiards venues';
    RAISE NOTICE '   3. matches (24 columns) - Match management';
    RAISE NOTICE '   4. tournaments (20 columns) - Tournament system';
    RAISE NOTICE '   5. match_requests (18 columns) - Challenge system';
    RAISE NOTICE '   6. notifications (15 columns) - Notification system';
    RAISE NOTICE '   7. tournament_participants (17 columns) - Tournament registration';
    RAISE NOTICE '   8. transactions (16 columns) - ELO/SPA tracking';
    RAISE NOTICE '   9. club_members (6 columns) - Club membership';
    RAISE NOTICE '';
    RAISE NOTICE '✅ All indexes created for optimal performance';
    RAISE NOTICE '✅ Row Level Security enabled with basic policies';
    RAISE NOTICE '✅ Database ready for Sabo Arena billiards management!';
END $$;