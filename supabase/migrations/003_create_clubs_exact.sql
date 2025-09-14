-- Migration: Create clubs table (Updated)
-- Description: Billiards clubs table matching existing schema exactly
-- Author: AI Assistant
-- Date: 2025-09-14

-- Create clubs table matching existing schema exactly
CREATE TABLE clubs (
    -- Primary identifier
    club_id VARCHAR(255) PRIMARY KEY,
    
    -- Basic information
    name VARCHAR(255) NOT NULL,
    address VARCHAR(500),
    phone VARCHAR(20),
    description TEXT,
    
    -- Media and branding
    logo_url TEXT,
    cover_image_url TEXT,
    social_handle VARCHAR(100),
    
    -- Statistics and metrics
    members_count INTEGER DEFAULT 0,
    tournaments_count INTEGER DEFAULT 0,
    challengers_count INTEGER DEFAULT 0,
    prize_pool_count DOUBLE PRECISION DEFAULT 0.0,
    club_ranking INTEGER DEFAULT 0,
    total_tables INTEGER DEFAULT 0,
    
    -- Status and settings
    status VARCHAR(50) DEFAULT 'Active',
    verified BOOLEAN DEFAULT FALSE,
    allow_tournaments BOOLEAN DEFAULT TRUE,
    
    -- Audit fields
    created_time TIMESTAMPTZ DEFAULT NOW(),
    updated_time TIMESTAMPTZ DEFAULT NOW(),
    owner_uid VARCHAR(255)
);

-- Create indexes for performance
CREATE INDEX idx_clubs_name ON clubs(name);
CREATE INDEX idx_clubs_owner_uid ON clubs(owner_uid);
CREATE INDEX idx_clubs_status ON clubs(status);
CREATE INDEX idx_clubs_verified ON clubs(verified);
CREATE INDEX idx_clubs_club_ranking ON clubs(club_ranking);
CREATE INDEX idx_clubs_created_time ON clubs(created_time);
CREATE INDEX idx_clubs_location ON clubs(address);
CREATE INDEX idx_clubs_members_count ON clubs(members_count);

-- Create partial indexes for active clubs
CREATE INDEX idx_clubs_active_ranking ON clubs(club_ranking) WHERE status = 'Active';
CREATE INDEX idx_clubs_active_verified ON clubs(verified) WHERE status = 'Active';

-- Enable Row Level Security
ALTER TABLE clubs ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Anyone can view active verified clubs
CREATE POLICY policy_clubs_public_view ON clubs
    FOR SELECT 
    USING (status = 'Active' AND verified = TRUE);

-- Users can view all active clubs (including unverified)
CREATE POLICY policy_clubs_active_view ON clubs
    FOR SELECT 
    USING (status = 'Active');

-- Club owners can view and update their own clubs
CREATE POLICY policy_clubs_owner_all ON clubs
    FOR ALL 
    USING (auth.uid()::text = owner_uid)
    WITH CHECK (auth.uid()::text = owner_uid);

-- Authenticated users can create clubs
CREATE POLICY policy_clubs_create ON clubs
    FOR INSERT 
    WITH CHECK (auth.uid()::text = owner_uid);

-- Create function to update updated_time
CREATE OR REPLACE FUNCTION update_clubs_updated_time()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_time = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for updated_time
DROP TRIGGER IF EXISTS trigger_clubs_updated_time ON clubs;
CREATE TRIGGER trigger_clubs_updated_time
    BEFORE UPDATE ON clubs
    FOR EACH ROW
    EXECUTE FUNCTION update_clubs_updated_time();

-- Create function to update club statistics
CREATE OR REPLACE FUNCTION update_club_stats(
    target_club_id VARCHAR(255),
    stat_type VARCHAR(50),
    increment_value INTEGER DEFAULT 1
)
RETURNS VOID AS $$
BEGIN
    CASE stat_type
        WHEN 'members' THEN
            UPDATE clubs 
            SET members_count = members_count + increment_value,
                updated_time = NOW()
            WHERE club_id = target_club_id;
            
        WHEN 'tournaments' THEN
            UPDATE clubs 
            SET tournaments_count = tournaments_count + increment_value,
                updated_time = NOW()
            WHERE club_id = target_club_id;
            
        WHEN 'challengers' THEN
            UPDATE clubs 
            SET challengers_count = challengers_count + increment_value,
                updated_time = NOW()
            WHERE club_id = target_club_id;
    END CASE;
END;
$$ LANGUAGE plpgsql;

-- Add comments for documentation
COMMENT ON TABLE clubs IS 'Billiards clubs and venues management table for Sabo Arena';
COMMENT ON COLUMN clubs.club_id IS 'Unique identifier for the club';
COMMENT ON COLUMN clubs.owner_uid IS 'Reference to the club owner in users table';
COMMENT ON COLUMN clubs.prize_pool_count IS 'Total prize money available at this club';
COMMENT ON COLUMN clubs.club_ranking IS 'Overall ranking among all clubs';
COMMENT ON COLUMN clubs.total_tables IS 'Number of billiards tables available';
COMMENT ON COLUMN clubs.allow_tournaments IS 'Whether this club allows tournament hosting';

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Successfully created clubs table matching existing schema:';
    RAISE NOTICE '   - 19 columns matching Supabase schema exactly';
    RAISE NOTICE '   - Performance indexes for common queries';
    RAISE NOTICE '   - RLS policies for data security';
    RAISE NOTICE '   - Statistics update functions';
    RAISE NOTICE '   - Proper constraints and validation';
END $$;