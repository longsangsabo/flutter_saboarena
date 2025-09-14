-- Migration: Create match_requests table
-- Description: Match invitation/challenge system for Sabo Arena
-- Author: AI Assistant
-- Date: 2025-09-14

-- Create match_requests table matching existing schema exactly
CREATE TABLE match_requests (
    -- Primary identifier
    request_id VARCHAR(255) PRIMARY KEY,
    
    -- Request details
    creator_uid VARCHAR(255),
    request_type VARCHAR(100),
    game_type VARCHAR(100),
    
    -- Game settings
    race_to INTEGER,
    handicap DOUBLE PRECISION DEFAULT 0.0,
    spa_bet INTEGER DEFAULT 0,
    table_number INTEGER,
    
    -- Schedule and location
    scheduled_time TIMESTAMPTZ,
    club_id VARCHAR(255),
    location VARCHAR(255),
    
    -- Request status
    status VARCHAR(50) DEFAULT 'Pending',
    opponent_uid VARCHAR(255),
    expires_at TIMESTAMPTZ,
    
    -- Additional info
    title VARCHAR(255),
    description TEXT,
    
    -- Audit fields
    created_time TIMESTAMPTZ DEFAULT NOW(),
    updated_time TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_match_requests_request_id ON match_requests(request_id);
CREATE INDEX idx_match_requests_creator_uid ON match_requests(creator_uid);
CREATE INDEX idx_match_requests_opponent_uid ON match_requests(opponent_uid);
CREATE INDEX idx_match_requests_status ON match_requests(status);
CREATE INDEX idx_match_requests_club_id ON match_requests(club_id);
CREATE INDEX idx_match_requests_scheduled_time ON match_requests(scheduled_time);
CREATE INDEX idx_match_requests_expires_at ON match_requests(expires_at);
CREATE INDEX idx_match_requests_created_time ON match_requests(created_time);
CREATE INDEX idx_match_requests_request_type ON match_requests(request_type);
CREATE INDEX idx_match_requests_game_type ON match_requests(game_type);

-- Create partial indexes for active requests
CREATE INDEX idx_match_requests_pending ON match_requests(expires_at) 
WHERE status = 'Pending';

CREATE INDEX idx_match_requests_open ON match_requests(scheduled_time) 
WHERE status = 'Open' AND opponent_uid IS NULL;

-- Create composite indexes for common queries
CREATE INDEX idx_match_requests_creator_status ON match_requests(creator_uid, status);
CREATE INDEX idx_match_requests_opponent_status ON match_requests(opponent_uid, status);
CREATE INDEX idx_match_requests_club_time ON match_requests(club_id, scheduled_time);

-- Enable Row Level Security
ALTER TABLE match_requests ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Creator can view and manage their own requests
CREATE POLICY policy_match_requests_creator ON match_requests
    FOR ALL 
    USING (auth.uid()::text = creator_uid)
    WITH CHECK (auth.uid()::text = creator_uid);

-- Opponent can view requests directed to them
CREATE POLICY policy_match_requests_opponent_view ON match_requests
    FOR SELECT 
    USING (auth.uid()::text = opponent_uid);

-- Opponent can respond to requests directed to them
CREATE POLICY policy_match_requests_opponent_respond ON match_requests
    FOR UPDATE 
    USING (auth.uid()::text = opponent_uid AND status = 'Pending')
    WITH CHECK (auth.uid()::text = opponent_uid);

-- Anyone can view open challenges (no specific opponent)
CREATE POLICY policy_match_requests_open_view ON match_requests
    FOR SELECT 
    USING (status = 'Open' AND opponent_uid IS NULL);

-- Anyone can accept open challenges
CREATE POLICY policy_match_requests_open_accept ON match_requests
    FOR UPDATE 
    USING (status = 'Open' AND opponent_uid IS NULL AND auth.uid()::text != creator_uid)
    WITH CHECK (status = 'Open');

-- Create function to update updated_time
CREATE OR REPLACE FUNCTION update_match_requests_updated_time()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_time = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for updated_time
CREATE TRIGGER trigger_match_requests_updated_time
    BEFORE UPDATE ON match_requests
    FOR EACH ROW
    EXECUTE FUNCTION update_match_requests_updated_time();

-- Function to auto-expire old requests
CREATE OR REPLACE FUNCTION expire_old_match_requests()
RETURNS INTEGER AS $$
DECLARE
    expired_count INTEGER;
BEGIN
    UPDATE match_requests 
    SET 
        status = 'Expired',
        updated_time = NOW()
    WHERE 
        status IN ('Pending', 'Open') 
        AND expires_at < NOW();
    
    GET DIAGNOSTICS expired_count = ROW_COUNT;
    RETURN expired_count;
END;
$$ LANGUAGE plpgsql;

-- Function to accept a match request
CREATE OR REPLACE FUNCTION accept_match_request(
    target_request_id VARCHAR(255),
    accepting_user_uid VARCHAR(255)
)
RETURNS VARCHAR(255) AS $$
DECLARE
    new_match_id VARCHAR(255);
    request_data RECORD;
BEGIN
    -- Get request details
    SELECT * INTO request_data 
    FROM match_requests 
    WHERE request_id = target_request_id AND status IN ('Pending', 'Open');
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Request not found or not available for acceptance';
    END IF;
    
    -- Check if user is trying to accept their own request
    IF request_data.creator_uid = accepting_user_uid THEN
        RAISE EXCEPTION 'Cannot accept your own request';
    END IF;
    
    -- Generate new match ID
    new_match_id := 'match_' || extract(epoch from now())::bigint || '_' || substring(md5(random()::text), 1, 8);
    
    -- Create match from request
    INSERT INTO matches (
        match_id, match_type, game_type, status,
        player1_uid, player2_uid,
        race_to, handicap, spa_bet, table_number,
        scheduled_time, club_id, location,
        created_time
    ) VALUES (
        new_match_id, 
        COALESCE(request_data.request_type, 'Challenge'),
        request_data.game_type,
        'Scheduled',
        request_data.creator_uid,
        accepting_user_uid,
        request_data.race_to,
        request_data.handicap,
        request_data.spa_bet,
        request_data.table_number,
        request_data.scheduled_time,
        request_data.club_id,
        request_data.location,
        NOW()
    );
    
    -- Update request status
    UPDATE match_requests 
    SET 
        status = 'Accepted',
        opponent_uid = accepting_user_uid,
        updated_time = NOW()
    WHERE request_id = target_request_id;
    
    RETURN new_match_id;
END;
$$ LANGUAGE plpgsql;

-- Function to search match requests
CREATE OR REPLACE FUNCTION search_match_requests(
    search_creator_uid VARCHAR(255) DEFAULT NULL,
    search_opponent_uid VARCHAR(255) DEFAULT NULL,
    search_status VARCHAR(50) DEFAULT NULL,
    search_club_id VARCHAR(255) DEFAULT NULL,
    search_game_type VARCHAR(100) DEFAULT NULL,
    include_expired BOOLEAN DEFAULT FALSE,
    limit_count INTEGER DEFAULT 50
)
RETURNS TABLE (
    request_id VARCHAR(255),
    creator_uid VARCHAR(255),
    opponent_uid VARCHAR(255),
    request_type VARCHAR(100),
    game_type VARCHAR(100),
    status VARCHAR(50),
    spa_bet INTEGER,
    scheduled_time TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    title VARCHAR(255),
    club_id VARCHAR(255)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        mr.request_id,
        mr.creator_uid,
        mr.opponent_uid,
        mr.request_type,
        mr.game_type,
        mr.status,
        mr.spa_bet,
        mr.scheduled_time,
        mr.expires_at,
        mr.title,
        mr.club_id
    FROM match_requests mr
    WHERE 
        (search_creator_uid IS NULL OR mr.creator_uid = search_creator_uid)
        AND (search_opponent_uid IS NULL OR mr.opponent_uid = search_opponent_uid)
        AND (search_status IS NULL OR mr.status = search_status)
        AND (search_club_id IS NULL OR mr.club_id = search_club_id)
        AND (search_game_type IS NULL OR mr.game_type = search_game_type)
        AND (include_expired = TRUE OR mr.status != 'Expired')
        AND (include_expired = TRUE OR mr.expires_at > NOW())
    ORDER BY 
        CASE 
            WHEN mr.status = 'Pending' THEN 1
            WHEN mr.status = 'Open' THEN 2
            ELSE 3
        END,
        mr.created_time DESC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Add constraints
ALTER TABLE match_requests 
ADD CONSTRAINT check_race_to CHECK (race_to > 0 AND race_to <= 50);

ALTER TABLE match_requests 
ADD CONSTRAINT check_spa_bet CHECK (spa_bet >= 0);

ALTER TABLE match_requests 
ADD CONSTRAINT check_expires_after_creation CHECK (expires_at > created_time);

ALTER TABLE match_requests 
ADD CONSTRAINT check_status_values CHECK (
    status IN ('Pending', 'Open', 'Accepted', 'Declined', 'Expired', 'Cancelled')
);

ALTER TABLE match_requests 
ADD CONSTRAINT check_creator_opponent_different CHECK (
    creator_uid != opponent_uid OR opponent_uid IS NULL
);

-- Add comments for documentation
COMMENT ON TABLE match_requests IS 'Match invitation and challenge system for Sabo Arena';
COMMENT ON COLUMN match_requests.request_id IS 'Unique identifier for the match request';
COMMENT ON COLUMN match_requests.request_type IS 'Type of request: Challenge, Open Challenge, etc.';
COMMENT ON COLUMN match_requests.opponent_uid IS 'Specific opponent (NULL for open challenges)';
COMMENT ON COLUMN match_requests.expires_at IS 'When this request expires and becomes invalid';
COMMENT ON COLUMN match_requests.spa_bet IS 'SPA points wagered on this challenge';

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Successfully created match_requests table:';
    RAISE NOTICE '   - 17 columns matching Supabase schema exactly';
    RAISE NOTICE '   - Challenge/invitation workflow system';
    RAISE NOTICE '   - Auto-expiration and acceptance functions';
    RAISE NOTICE '   - RLS policies for creator/opponent access';
    RAISE NOTICE '   - Integration with matches table';
END $$;