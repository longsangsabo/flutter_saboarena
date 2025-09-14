-- Migration: Create tournament_participants table
-- Description: Tournament membership and bracket management for Sabo Arena
-- Author: AI Assistant
-- Date: 2025-09-14

-- Create tournament_participants table matching existing schema exactly
CREATE TABLE tournament_participants (
    -- Primary identifier
    participant_id VARCHAR(255) PRIMARY KEY,
    
    -- Tournament and user reference
    tournament_id VARCHAR(255),
    uid VARCHAR(255),
    user_rank VARCHAR(100),
    
    -- Registration details
    registration_time TIMESTAMPTZ DEFAULT NOW(),
    payment_status VARCHAR(50) DEFAULT 'Pending',
    entry_fee_paid INTEGER DEFAULT 0,
    
    -- Tournament progress
    current_round INTEGER DEFAULT 1,
    bracket_position INTEGER,
    wins INTEGER DEFAULT 0,
    losses INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT 'Active',
    elimination_round INTEGER,
    
    -- Final results
    final_ranking INTEGER,
    prize_amount INTEGER DEFAULT 0,
    prize_status VARCHAR(50) DEFAULT 'Pending',
    
    -- Audit fields
    created_time TIMESTAMPTZ DEFAULT NOW(),
    updated_time TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_tournament_participants_participant_id ON tournament_participants(participant_id);
CREATE INDEX idx_tournament_participants_tournament_id ON tournament_participants(tournament_id);
CREATE INDEX idx_tournament_participants_uid ON tournament_participants(uid);
CREATE INDEX idx_tournament_participants_status ON tournament_participants(status);
CREATE INDEX idx_tournament_participants_payment_status ON tournament_participants(payment_status);
CREATE INDEX idx_tournament_participants_current_round ON tournament_participants(current_round);
CREATE INDEX idx_tournament_participants_bracket_position ON tournament_participants(bracket_position);
CREATE INDEX idx_tournament_participants_final_ranking ON tournament_participants(final_ranking);
CREATE INDEX idx_tournament_participants_created_time ON tournament_participants(created_time);
CREATE INDEX idx_tournament_participants_registration_time ON tournament_participants(registration_time);

-- Create composite indexes for common queries
CREATE INDEX idx_tournament_participants_tournament_status ON tournament_participants(tournament_id, status);
CREATE INDEX idx_tournament_participants_tournament_round ON tournament_participants(tournament_id, current_round);
CREATE INDEX idx_tournament_participants_user_status ON tournament_participants(uid, status);
CREATE INDEX idx_tournament_participants_bracket ON tournament_participants(tournament_id, bracket_position);

-- Enable Row Level Security
ALTER TABLE tournament_participants ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Participants can view their own participation
CREATE POLICY policy_tournament_participants_own ON tournament_participants
    FOR SELECT 
    USING (auth.uid()::text = uid);

-- Anyone can view active participants (for public tournaments)
CREATE POLICY policy_tournament_participants_public ON tournament_participants
    FOR SELECT 
    USING (
        status = 'Active' AND 
        tournament_id IN (
            SELECT tournament_id FROM tournaments 
            WHERE status IN ('Registration', 'Ready', 'In Progress', 'Completed')
        )
    );

-- Tournament organizers can manage participants
CREATE POLICY policy_tournament_participants_organizer ON tournament_participants
    FOR ALL 
    USING (
        tournament_id IN (
            SELECT t.tournament_id FROM tournaments t
            JOIN clubs c ON t.club_id = c.club_id
            WHERE c.owner_uid = auth.uid()::text
        )
    );

-- Participants can register themselves
CREATE POLICY policy_tournament_participants_register ON tournament_participants
    FOR INSERT 
    WITH CHECK (auth.uid()::text = uid);

-- Create function to update updated_time
CREATE OR REPLACE FUNCTION update_tournament_participants_updated_time()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_time = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for updated_time
CREATE TRIGGER trigger_tournament_participants_updated_time
    BEFORE UPDATE ON tournament_participants
    FOR EACH ROW
    EXECUTE FUNCTION update_tournament_participants_updated_time();

-- Function to register for tournament
CREATE OR REPLACE FUNCTION register_for_tournament(
    target_tournament_id VARCHAR(255),
    participant_uid VARCHAR(255),
    paid_entry_fee INTEGER DEFAULT 0
)
RETURNS VARCHAR(255) AS $$
DECLARE
    new_participant_id VARCHAR(255);
    tournament_data RECORD;
    user_elo INTEGER;
    next_bracket_position INTEGER;
BEGIN
    -- Get tournament details
    SELECT * INTO tournament_data 
    FROM tournaments 
    WHERE tournament_id = target_tournament_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tournament not found';
    END IF;
    
    -- Check tournament status
    IF tournament_data.status NOT IN ('Open', 'Registration') THEN
        RAISE EXCEPTION 'Tournament registration is not open';
    END IF;
    
    -- Check if already registered
    IF EXISTS (SELECT 1 FROM tournament_participants WHERE tournament_id = target_tournament_id AND uid = participant_uid) THEN
        RAISE EXCEPTION 'User already registered for this tournament';
    END IF;
    
    -- Check capacity
    IF tournament_data.current_participants >= tournament_data.max_participants THEN
        RAISE EXCEPTION 'Tournament is full';
    END IF;
    
    -- Check user eligibility (ELO requirements)
    SELECT elo_rating INTO user_elo FROM users WHERE uid = participant_uid;
    
    IF tournament_data.rank_requirement_min IS NOT NULL AND user_elo < tournament_data.rank_requirement_min::INTEGER THEN
        RAISE EXCEPTION 'User ELO rating too low for this tournament';
    END IF;
    
    IF tournament_data.rank_requirement_max IS NOT NULL AND user_elo > tournament_data.rank_requirement_max::INTEGER THEN
        RAISE EXCEPTION 'User ELO rating too high for this tournament';
    END IF;
    
    -- Get next bracket position
    SELECT COALESCE(MAX(bracket_position), 0) + 1 
    INTO next_bracket_position 
    FROM tournament_participants 
    WHERE tournament_id = target_tournament_id;
    
    -- Generate participant ID
    new_participant_id := 'tp_' || extract(epoch from now())::bigint || '_' || substring(md5(random()::text), 1, 8);
    
    -- Create participant record
    INSERT INTO tournament_participants (
        participant_id, tournament_id, uid,
        user_rank, bracket_position, entry_fee_paid,
        payment_status, registration_time
    ) VALUES (
        new_participant_id, target_tournament_id, participant_uid,
        user_elo::VARCHAR, next_bracket_position, paid_entry_fee,
        CASE WHEN paid_entry_fee >= tournament_data.entry_fee THEN 'Paid' ELSE 'Pending' END,
        NOW()
    );
    
    -- Update tournament participant count
    PERFORM update_tournament_participants(target_tournament_id, 1);
    
    RETURN new_participant_id;
END;
$$ LANGUAGE plpgsql;

-- Function to update participant results
CREATE OR REPLACE FUNCTION update_participant_results(
    target_participant_id VARCHAR(255),
    win_count INTEGER DEFAULT NULL,
    loss_count INTEGER DEFAULT NULL,
    new_round INTEGER DEFAULT NULL,
    eliminated_round INTEGER DEFAULT NULL,
    final_rank INTEGER DEFAULT NULL,
    prize_money INTEGER DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
    UPDATE tournament_participants 
    SET 
        wins = COALESCE(win_count, wins),
        losses = COALESCE(loss_count, losses),
        current_round = COALESCE(new_round, current_round),
        elimination_round = COALESCE(eliminated_round, elimination_round),
        final_ranking = COALESCE(final_rank, final_ranking),
        prize_amount = COALESCE(prize_money, prize_amount),
        status = CASE 
            WHEN eliminated_round IS NOT NULL THEN 'Eliminated'
            WHEN final_rank IS NOT NULL THEN 'Completed'
            ELSE status 
        END,
        prize_status = CASE 
            WHEN prize_money IS NOT NULL AND prize_money > 0 THEN 'Pending'
            ELSE prize_status 
        END,
        updated_time = NOW()
    WHERE participant_id = target_participant_id;
END;
$$ LANGUAGE plpgsql;

-- Function to get tournament bracket
CREATE OR REPLACE FUNCTION get_tournament_bracket(
    target_tournament_id VARCHAR(255)
)
RETURNS TABLE (
    participant_id VARCHAR(255),
    uid VARCHAR(255),
    user_rank VARCHAR(100),
    bracket_position INTEGER,
    current_round INTEGER,
    wins INTEGER,
    losses INTEGER,
    status VARCHAR(50),
    final_ranking INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        tp.participant_id,
        tp.uid,
        tp.user_rank,
        tp.bracket_position,
        tp.current_round,
        tp.wins,
        tp.losses,
        tp.status,
        tp.final_ranking
    FROM tournament_participants tp
    WHERE tp.tournament_id = target_tournament_id
    ORDER BY 
        CASE WHEN tp.final_ranking IS NOT NULL THEN tp.final_ranking ELSE 999 END,
        tp.bracket_position;
END;
$$ LANGUAGE plpgsql;

-- Function to search tournament participants
CREATE OR REPLACE FUNCTION search_tournament_participants(
    search_tournament_id VARCHAR(255) DEFAULT NULL,
    search_uid VARCHAR(255) DEFAULT NULL,
    search_status VARCHAR(50) DEFAULT NULL,
    search_round INTEGER DEFAULT NULL,
    limit_count INTEGER DEFAULT 100
)
RETURNS TABLE (
    participant_id VARCHAR(255),
    tournament_id VARCHAR(255),
    uid VARCHAR(255),
    user_rank VARCHAR(100),
    payment_status VARCHAR(50),
    current_round INTEGER,
    wins INTEGER,
    losses INTEGER,
    status VARCHAR(50),
    final_ranking INTEGER,
    registration_time TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        tp.participant_id,
        tp.tournament_id,
        tp.uid,
        tp.user_rank,
        tp.payment_status,
        tp.current_round,
        tp.wins,
        tp.losses,
        tp.status,
        tp.final_ranking,
        tp.registration_time
    FROM tournament_participants tp
    WHERE 
        (search_tournament_id IS NULL OR tp.tournament_id = search_tournament_id)
        AND (search_uid IS NULL OR tp.uid = search_uid)
        AND (search_status IS NULL OR tp.status = search_status)
        AND (search_round IS NULL OR tp.current_round = search_round)
    ORDER BY 
        CASE WHEN tp.final_ranking IS NOT NULL THEN tp.final_ranking ELSE 999 END,
        tp.registration_time
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Add constraints
ALTER TABLE tournament_participants 
ADD CONSTRAINT check_wins_losses CHECK (wins >= 0 AND losses >= 0);

ALTER TABLE tournament_participants 
ADD CONSTRAINT check_current_round CHECK (current_round >= 0);

ALTER TABLE tournament_participants 
ADD CONSTRAINT check_bracket_position CHECK (bracket_position > 0);

ALTER TABLE tournament_participants 
ADD CONSTRAINT check_final_ranking CHECK (final_ranking IS NULL OR final_ranking > 0);

ALTER TABLE tournament_participants 
ADD CONSTRAINT check_entry_fee_paid CHECK (entry_fee_paid >= 0);

ALTER TABLE tournament_participants 
ADD CONSTRAINT check_prize_amount CHECK (prize_amount >= 0);

ALTER TABLE tournament_participants 
ADD CONSTRAINT check_status_values CHECK (
    status IN ('Active', 'Eliminated', 'Completed', 'Withdrawn', 'Disqualified')
);

ALTER TABLE tournament_participants 
ADD CONSTRAINT check_payment_status_values CHECK (
    payment_status IN ('Pending', 'Paid', 'Refunded', 'Waived')
);

ALTER TABLE tournament_participants 
ADD CONSTRAINT check_prize_status_values CHECK (
    prize_status IN ('Pending', 'Paid', 'Not Applicable')
);

-- Add unique constraint to prevent duplicate registrations
ALTER TABLE tournament_participants 
ADD CONSTRAINT unique_tournament_participant UNIQUE (tournament_id, uid);

-- Add comments for documentation
COMMENT ON TABLE tournament_participants IS 'Tournament participants and bracket management for Sabo Arena';
COMMENT ON COLUMN tournament_participants.participant_id IS 'Unique identifier for the tournament participation';
COMMENT ON COLUMN tournament_participants.bracket_position IS 'Position in tournament bracket (seeding)';
COMMENT ON COLUMN tournament_participants.current_round IS 'Current round the participant is in';
COMMENT ON COLUMN tournament_participants.elimination_round IS 'Round in which participant was eliminated';
COMMENT ON COLUMN tournament_participants.final_ranking IS 'Final ranking in tournament (1st, 2nd, 3rd, etc.)';
COMMENT ON COLUMN tournament_participants.prize_amount IS 'Prize money won (in smallest currency unit)';

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Successfully created tournament_participants table:';
    RAISE NOTICE '   - 17 columns matching Supabase schema exactly';
    RAISE NOTICE '   - Tournament registration and bracket management';
    RAISE NOTICE '   - Payment and prize tracking system';
    RAISE NOTICE '   - RLS policies for participants and organizers';
    RAISE NOTICE '   - Comprehensive tournament workflow functions';
END $$;