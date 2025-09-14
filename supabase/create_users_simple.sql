-- COPY AND PASTE THIS INTO SUPABASE SQL EDITOR
-- Simple users table creation for Sabo Arena

-- Enable UUID extension if not exists
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    email VARCHAR(255),
    display_name VARCHAR(255),
    photo_url TEXT,
    uid VARCHAR(255),
    created_time TIMESTAMPTZ DEFAULT NOW(),
    phone_number VARCHAR(20),
    location VARCHAR(255),
    total_matches INTEGER DEFAULT 0,
    overall_ranking INTEGER DEFAULT 0,
    win_rate DOUBLE PRECISION DEFAULT 0.0,
    is_online BOOLEAN DEFAULT FALSE,
    last_active TIMESTAMPTZ,
    account_status VARCHAR(50) DEFAULT 'Active',
    updated_time TIMESTAMPTZ DEFAULT NOW(),
    full_name VARCHAR(255),
    rank VARCHAR(100),
    elo_rating INTEGER DEFAULT 1200,
    spa_points INTEGER DEFAULT 0,
    bio TEXT,
    preferred_game_type VARCHAR(100),
    available_times TEXT[],
    followers_count INTEGER DEFAULT 0,
    following_count INTEGER DEFAULT 0,
    club_id VARCHAR(255),
    user_name VARCHAR(100)
);

-- Create basic indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_uid ON users(uid);
CREATE INDEX IF NOT EXISTS idx_users_user_name ON users(user_name);
CREATE INDEX IF NOT EXISTS idx_users_elo_rating ON users(elo_rating);
CREATE INDEX IF NOT EXISTS idx_users_is_online ON users(is_online);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create basic RLS policy - allow all for now
CREATE POLICY IF NOT EXISTS policy_users_all ON users FOR ALL USING (true);

-- Success message
SELECT 'Users table created successfully!' as status;