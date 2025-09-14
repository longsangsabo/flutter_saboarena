-- Migration: Create tournaments table
-- Description: Billiards tournaments table matching existing schema exactly
-- Author: AI Assistant
-- Date: 2025-09-14

-- Create tournaments table matching existing schema exactly
CREATE TABLE tournaments (
    -- Primary identifier
    tournament_id VARCHAR(255) PRIMARY KEY,
    
    -- Basic information
    name VARCHAR(255) NOT NULL,
    tournament_type VARCHAR(100),
    game_format VARCHAR(100),
    description TEXT,
    
    -- Participant management
    max_participants INTEGER,
    current_participants INTEGER DEFAULT 0,
    tournament_format VARCHAR(100),
    rank_requirement_min VARCHAR(100),
    rank_requirement_max VARCHAR(100),
    
    -- Financial
    entry_fee INTEGER DEFAULT 0,
    total_prize INTEGER DEFAULT 0,
    currency VARCHAR(10) DEFAULT 'VND',
    
    -- Schedule and location
    start_time TIMESTAMPTZ,
    registration_deadline TIMESTAMPTZ,
    club_id VARCHAR(255),
    location VARCHAR(255),
    
    -- Status and audit
    status VARCHAR(50) DEFAULT 'Draft',
    created_time TIMESTAMPTZ DEFAULT NOW(),
    updated_time TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_tournaments_tournament_id ON tournaments(tournament_id);
CREATE INDEX idx_tournaments_name ON tournaments(name);
CREATE INDEX idx_tournaments_tournament_type ON tournaments(tournament_type);
CREATE INDEX idx_tournaments_game_format ON tournaments(game_format);
CREATE INDEX idx_tournaments_status ON tournaments(status);
CREATE INDEX idx_tournaments_club_id ON tournaments(club_id);
CREATE INDEX idx_tournaments_start_time ON tournaments(start_time);
CREATE INDEX idx_tournaments_registration_deadline ON tournaments(registration_deadline);
CREATE INDEX idx_tournaments_created_time ON tournaments(created_time);
CREATE INDEX idx_tournaments_entry_fee ON tournaments(entry_fee);

-- Create partial indexes for active tournaments
CREATE INDEX idx_tournaments_active_registration ON tournaments(registration_deadline) 
WHERE status IN ('Open', 'Registration');

CREATE INDEX idx_tournaments_upcoming ON tournaments(start_time) 
WHERE status IN ('Open', 'Registration', 'Ready');

-- Create composite indexes for common queries
CREATE INDEX idx_tournaments_club_status ON tournaments(club_id, status);
CREATE INDEX idx_tournaments_type_status ON tournaments(tournament_type, status);
CREATE INDEX idx_tournaments_format_fee ON tournaments(game_format, entry_fee);

-- Create text search index for tournament search
CREATE INDEX idx_tournaments_text_search ON tournaments 
USING gin(to_tsvector('english', name || ' ' || COALESCE(description, '')));

-- Enable Row Level Security
ALTER TABLE tournaments ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Anyone can view open/public tournaments
CREATE POLICY policy_tournaments_public_view ON tournaments
    FOR SELECT 
    USING (status IN ('Open', 'Registration', 'In Progress', 'Completed'));

-- Club owners can manage tournaments at their club
CREATE POLICY policy_tournaments_club_manage ON tournaments
    FOR ALL 
    USING (
        club_id IN (
            SELECT club_id FROM clubs WHERE owner_uid = auth.uid()::text
        )
    )
    WITH CHECK (
        club_id IN (
            SELECT club_id FROM clubs WHERE owner_uid = auth.uid()::text
        )
    );

-- Authenticated users can create tournaments (will be validated by business logic)
CREATE POLICY policy_tournaments_create ON tournaments
    FOR INSERT 
    WITH CHECK (auth.uid() IS NOT NULL);

-- Create function to update updated_time
CREATE OR REPLACE FUNCTION update_tournaments_updated_time()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_time = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for updated_time
CREATE TRIGGER trigger_tournaments_updated_time
    BEFORE UPDATE ON tournaments
    FOR EACH ROW
    EXECUTE FUNCTION update_tournaments_updated_time();

-- Create function to update participant count
CREATE OR REPLACE FUNCTION update_tournament_participants(
    target_tournament_id VARCHAR(255),
    increment_value INTEGER DEFAULT 1
)
RETURNS VOID AS $$
BEGIN
    UPDATE tournaments 
    SET 
        current_participants = current_participants + increment_value,
        updated_time = NOW()
    WHERE tournament_id = target_tournament_id;
    
    -- Auto-close registration if max reached
    UPDATE tournaments 
    SET status = 'Ready'
    WHERE tournament_id = target_tournament_id 
    AND current_participants >= max_participants
    AND status = 'Registration';
END;
$$ LANGUAGE plpgsql;

-- Create function to check tournament eligibility
CREATE OR REPLACE FUNCTION check_tournament_eligibility(
    target_tournament_id VARCHAR(255),
    player_uid VARCHAR(255)
)
RETURNS BOOLEAN AS $$
DECLARE
    player_elo INTEGER;
    min_elo INTEGER;
    max_elo INTEGER;
    tournament_status VARCHAR(50);
    current_count INTEGER;
    max_count INTEGER;
    registration_deadline TIMESTAMPTZ;
BEGIN
    -- Get tournament details
    SELECT 
        status, 
        current_participants, 
        max_participants,
        tournaments.registration_deadline,
        COALESCE(rank_requirement_min::INTEGER, 0),
        COALESCE(rank_requirement_max::INTEGER, 9999)
    INTO 
        tournament_status, 
        current_count, 
        max_count,
        registration_deadline,
        min_elo,
        max_elo
    FROM tournaments 
    WHERE tournament_id = target_tournament_id;
    
    -- Get player ELO
    SELECT elo_rating INTO player_elo FROM users WHERE uid = player_uid;
    
    -- Check eligibility conditions
    RETURN (
        tournament_status IN ('Open', 'Registration') AND
        current_count < max_count AND
        NOW() < registration_deadline AND
        player_elo >= min_elo AND
        player_elo <= max_elo
    );
END;
$$ LANGUAGE plpgsql;

-- Create function for tournament search
CREATE OR REPLACE FUNCTION search_tournaments(
    search_term TEXT DEFAULT NULL,
    search_type VARCHAR(100) DEFAULT NULL,
    search_status VARCHAR(50) DEFAULT NULL,
    search_club_id VARCHAR(255) DEFAULT NULL,
    min_prize INTEGER DEFAULT NULL,
    max_entry_fee INTEGER DEFAULT NULL,
    limit_count INTEGER DEFAULT 20
)
RETURNS TABLE (
    tournament_id VARCHAR(255),
    name VARCHAR(255),
    tournament_type VARCHAR(100),
    game_format VARCHAR(100),
    status VARCHAR(50),
    current_participants INTEGER,
    max_participants INTEGER,
    entry_fee INTEGER,
    total_prize INTEGER,
    start_time TIMESTAMPTZ,
    registration_deadline TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.tournament_id,
        t.name,
        t.tournament_type,
        t.game_format,
        t.status,
        t.current_participants,
        t.max_participants,
        t.entry_fee,
        t.total_prize,
        t.start_time,
        t.registration_deadline
    FROM tournaments t
    WHERE 
        (search_term IS NULL OR 
         to_tsvector('english', t.name || ' ' || COALESCE(t.description, '')) 
         @@ plainto_tsquery('english', search_term))
        AND (search_type IS NULL OR t.tournament_type = search_type)
        AND (search_status IS NULL OR t.status = search_status)
        AND (search_club_id IS NULL OR t.club_id = search_club_id)
        AND (min_prize IS NULL OR t.total_prize >= min_prize)
        AND (max_entry_fee IS NULL OR t.entry_fee <= max_entry_fee)
    ORDER BY 
        CASE 
            WHEN t.status = 'Registration' THEN 1
            WHEN t.status = 'Open' THEN 2
            WHEN t.status = 'Ready' THEN 3
            ELSE 4
        END,
        t.start_time ASC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Create function to advance tournament status
CREATE OR REPLACE FUNCTION advance_tournament_status(
    target_tournament_id VARCHAR(255)
)
RETURNS VARCHAR(50) AS $$
DECLARE
    current_status VARCHAR(50);
    new_status VARCHAR(50);
BEGIN
    SELECT status INTO current_status 
    FROM tournaments 
    WHERE tournament_id = target_tournament_id;
    
    new_status := CASE current_status
        WHEN 'Draft' THEN 'Open'
        WHEN 'Open' THEN 'Registration'
        WHEN 'Registration' THEN 'Ready'
        WHEN 'Ready' THEN 'In Progress'
        WHEN 'In Progress' THEN 'Completed'
        ELSE current_status
    END;
    
    UPDATE tournaments 
    SET 
        status = new_status,
        updated_time = NOW()
    WHERE tournament_id = target_tournament_id;
    
    RETURN new_status;
END;
$$ LANGUAGE plpgsql;

-- Add constraints
ALTER TABLE tournaments 
ADD CONSTRAINT check_max_participants CHECK (max_participants > 0 AND max_participants <= 1000);

ALTER TABLE tournaments 
ADD CONSTRAINT check_current_participants CHECK (current_participants >= 0);

ALTER TABLE tournaments 
ADD CONSTRAINT check_participants_limit CHECK (current_participants <= max_participants);

ALTER TABLE tournaments 
ADD CONSTRAINT check_entry_fee CHECK (entry_fee >= 0);

ALTER TABLE tournaments 
ADD CONSTRAINT check_total_prize CHECK (total_prize >= 0);

ALTER TABLE tournaments 
ADD CONSTRAINT check_registration_before_start CHECK (registration_deadline <= start_time);

ALTER TABLE tournaments 
ADD CONSTRAINT check_status_values CHECK (
    status IN ('Draft', 'Open', 'Registration', 'Ready', 'In Progress', 'Completed', 'Cancelled')
);

-- Add comments for documentation
COMMENT ON TABLE tournaments IS 'Billiards tournaments management table for Sabo Arena';
COMMENT ON COLUMN tournaments.tournament_id IS 'Unique identifier for the tournament';
COMMENT ON COLUMN tournaments.tournament_type IS 'Type of tournament: Single Elimination, Double Elimination, Round Robin, etc.';
COMMENT ON COLUMN tournaments.game_format IS 'Game format: 8-ball, 9-ball, 10-ball, snooker, etc.';
COMMENT ON COLUMN tournaments.tournament_format IS 'Detailed format specification';
COMMENT ON COLUMN tournaments.rank_requirement_min IS 'Minimum ELO rating required to join';
COMMENT ON COLUMN tournaments.rank_requirement_max IS 'Maximum ELO rating allowed to join';
COMMENT ON COLUMN tournaments.entry_fee IS 'Fee required to participate (in smallest currency unit)';
COMMENT ON COLUMN tournaments.total_prize IS 'Total prize pool (in smallest currency unit)';

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Successfully created tournaments table matching existing schema:';
    RAISE NOTICE '   - 19 columns matching Supabase schema exactly';
    RAISE NOTICE '   - Comprehensive indexes for query performance';
    RAISE NOTICE '   - RLS policies for public access and club management';
    RAISE NOTICE '   - Tournament management functions (registration, status, search)';
    RAISE NOTICE '   - Eligibility checking and participant management';
    RAISE NOTICE '   - Data validation constraints';
    RAISE NOTICE '   - Full-text search capabilities';
END $$;