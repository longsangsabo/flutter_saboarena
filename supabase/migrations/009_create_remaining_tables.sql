-- Migration: Create remaining tables (transactions, club_members)
-- Description: Complete the database schema for Sabo Arena
-- Author: AI Assistant  
-- Date: 2025-09-14

-- 4. CREATE TRANSACTIONS TABLE
CREATE TABLE transactions (
    -- Primary identifier
    transaction_id VARCHAR(255) PRIMARY KEY,
    
    -- Transaction details
    transaction_type VARCHAR(100),
    elo_change INTEGER DEFAULT 0,
    spa_change INTEGER DEFAULT 0,
    old_elo INTEGER,
    new_elo INTEGER,
    old_spa INTEGER,
    new_spa INTEGER,
    
    -- Source tracking
    source_type VARCHAR(100),
    source_id VARCHAR(255),
    description TEXT,
    
    -- Processing
    created_time TIMESTAMPTZ DEFAULT NOW(),
    processed_time TIMESTAMPTZ,
    status VARCHAR(50) DEFAULT 'Pending',
    requires_confirmation BOOLEAN DEFAULT FALSE,
    confirmed_by VARCHAR(255),
    
    -- User reference
    uid VARCHAR(255)
);

-- 5. CREATE CLUB_MEMBERS TABLE
CREATE TABLE club_members (
    -- Primary identifier
    member_id VARCHAR(255) PRIMARY KEY,
    
    -- References
    club_id VARCHAR(255),
    uid VARCHAR(255),
    
    -- Membership details
    role VARCHAR(50) DEFAULT 'Member',
    joined_time TIMESTAMPTZ DEFAULT NOW(),
    status VARCHAR(50) DEFAULT 'Active',
    
    -- Add unique constraint
    UNIQUE(club_id, uid)
);

-- Create indexes for transactions
CREATE INDEX idx_transactions_uid ON transactions(uid);
CREATE INDEX idx_transactions_type ON transactions(transaction_type);
CREATE INDEX idx_transactions_status ON transactions(status);
CREATE INDEX idx_transactions_source ON transactions(source_type, source_id);
CREATE INDEX idx_transactions_created_time ON transactions(created_time);

-- Create indexes for club_members  
CREATE INDEX idx_club_members_club_id ON club_members(club_id);
CREATE INDEX idx_club_members_uid ON club_members(uid);
CREATE INDEX idx_club_members_role ON club_members(role);
CREATE INDEX idx_club_members_status ON club_members(status);

-- Enable RLS
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE club_members ENABLE ROW LEVEL SECURITY;

-- RLS for transactions - users can view their own
CREATE POLICY policy_transactions_own ON transactions
    FOR SELECT USING (auth.uid()::text = uid);

-- RLS for club_members - members can view club membership
CREATE POLICY policy_club_members_view ON club_members
    FOR SELECT USING (
        auth.uid()::text = uid OR 
        club_id IN (SELECT club_id FROM club_members WHERE uid = auth.uid()::text)
    );

-- Add constraints
ALTER TABLE transactions ADD CONSTRAINT check_transaction_status 
CHECK (status IN ('Pending', 'Completed', 'Failed', 'Cancelled'));

ALTER TABLE club_members ADD CONSTRAINT check_member_role 
CHECK (role IN ('Owner', 'Admin', 'Manager', 'Member'));

ALTER TABLE club_members ADD CONSTRAINT check_member_status 
CHECK (status IN ('Active', 'Inactive', 'Banned'));

-- Comments
COMMENT ON TABLE transactions IS 'ELO and SPA points transaction history';
COMMENT ON TABLE club_members IS 'Club membership management';

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Successfully created remaining tables:';
    RAISE NOTICE '   - transactions: ELO/SPA transaction history';
    RAISE NOTICE '   - club_members: Club membership management';
    RAISE NOTICE '   - All indexes and constraints applied';
    RAISE NOTICE '   - RLS policies configured';
END $$;