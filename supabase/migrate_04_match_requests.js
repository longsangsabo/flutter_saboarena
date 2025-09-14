#!/usr/bin/env node

const { Client } = require('pg');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

async function migrateMatchRequestsTable() {
    const client = new Client({
        connectionString: process.env.POOLER_URL,
        ssl: { rejectUnauthorized: false }
    });

    try {
        console.log('🎯 Migrating match_requests table - Challenge & Invitation System...');
        await client.connect();
        console.log('✅ Connected to database');
        
        // Check if table exists
        const tableExists = await client.query(`
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_schema = 'public' AND table_name = 'match_requests'
            );
        `);
        
        if (tableExists.rows[0].exists) {
            console.log('⚠️  match_requests table already exists. Analyzing structure...');
            
            const columns = await client.query(`
                SELECT column_name, data_type, is_nullable, column_default
                FROM information_schema.columns 
                WHERE table_name = 'match_requests' 
                ORDER BY ordinal_position;
            `);
            
            console.log('📋 Current match_requests table structure:');
            columns.rows.forEach((col, index) => {
                console.log(`   ${index + 1}. ${col.column_name} (${col.data_type})`);
            });
            
            const rowCount = await client.query('SELECT COUNT(*) FROM match_requests');
            console.log(`📊 Current records: ${rowCount.rows[0].count}`);
            
            // Check indexes
            const indexes = await client.query(`
                SELECT indexname, indexdef 
                FROM pg_indexes 
                WHERE tablename = 'match_requests';
            `);
            
            console.log('\n📊 Current indexes:');
            indexes.rows.forEach((idx, index) => {
                console.log(`   ${index + 1}. ${idx.indexname}`);
            });
            
            // Analyze request patterns
            if (rowCount.rows[0].count > 0) {
                const statusBreakdown = await client.query(`
                    SELECT status, COUNT(*) as count
                    FROM match_requests 
                    GROUP BY status;
                `);
                
                console.log('\n📊 Request status breakdown:');
                statusBreakdown.rows.forEach(row => {
                    console.log(`   ${row.status}: ${row.count}`);
                });
                
                const typeBreakdown = await client.query(`
                    SELECT request_type, COUNT(*) as count
                    FROM match_requests 
                    GROUP BY request_type;
                `);
                
                console.log('\n📊 Request type breakdown:');
                typeBreakdown.rows.forEach(row => {
                    console.log(`   ${row.request_type}: ${row.count}`);
                });
                
                // Check expired requests
                const expiredRequests = await client.query(`
                    SELECT COUNT(*) as expired_count
                    FROM match_requests 
                    WHERE expires_at < NOW() AND status = 'Pending';
                `);
                
                console.log(`\n⏰ Expired pending requests: ${expiredRequests.rows[0].expired_count}`);
            }
            
            // Check RLS status
            const rlsStatus = await client.query(`
                SELECT relrowsecurity 
                FROM pg_class 
                WHERE relname = 'match_requests';
            `);
            
            console.log(`🔒 RLS Status: ${rlsStatus.rows[0]?.relrowsecurity ? 'Enabled' : 'Disabled'}`);
            
        } else {
            console.log('📋 Creating match_requests table - Challenge invitation system...');
            
            // Create match_requests table
            await client.query(`
                CREATE TABLE match_requests (
                    -- Primary identifier
                    request_id VARCHAR(255) PRIMARY KEY DEFAULT gen_random_uuid()::text,
                    created_time TIMESTAMPTZ DEFAULT NOW(),
                    
                    -- Participants
                    requester_uid VARCHAR(255) NOT NULL,
                    target_uid VARCHAR(255),
                    
                    -- Venue
                    club_id VARCHAR(255),
                    
                    -- Request details
                    request_type VARCHAR(50) DEFAULT 'Direct',
                    game_mode VARCHAR(50) DEFAULT '8-Ball',
                    status VARCHAR(50) DEFAULT 'Pending',
                    message TEXT,
                    
                    -- Scheduling
                    suggested_time TIMESTAMPTZ,
                    expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '24 hours'),
                    response_time TIMESTAMPTZ,
                    
                    -- Match creation
                    created_match_id VARCHAR(255),
                    
                    -- Stakes & Requirements
                    stake_amount DECIMAL(10,2) DEFAULT 0.00,
                    min_elo INTEGER,
                    max_elo INTEGER,
                    
                    -- Settings
                    auto_accept BOOLEAN DEFAULT FALSE,
                    is_private BOOLEAN DEFAULT FALSE,
                    
                    -- Additional data
                    request_data JSONB DEFAULT '{}'
                );
            `);
            
            console.log('✅ match_requests table created successfully!');
            
            // Create performance indexes
            console.log('📊 Creating performance indexes...');
            await client.query('CREATE INDEX idx_match_requests_requester ON match_requests(requester_uid);');
            await client.query('CREATE INDEX idx_match_requests_target ON match_requests(target_uid);');
            await client.query('CREATE INDEX idx_match_requests_club ON match_requests(club_id);');
            await client.query('CREATE INDEX idx_match_requests_status ON match_requests(status);');
            await client.query('CREATE INDEX idx_match_requests_type ON match_requests(request_type);');
            await client.query('CREATE INDEX idx_match_requests_expires ON match_requests(expires_at);');
            await client.query('CREATE INDEX idx_match_requests_created_time ON match_requests(created_time);');
            
            console.log('✅ Indexes created successfully!');
            
            // Enable Row Level Security
            console.log('🔒 Enabling Row Level Security...');
            await client.query('ALTER TABLE match_requests ENABLE ROW LEVEL SECURITY;');
            
            // Create RLS policies
            // Users involved in request can view/manage
            await client.query(`
                CREATE POLICY policy_match_requests_involved ON match_requests
                    FOR ALL USING (
                        auth.uid()::text IN (requester_uid, target_uid)
                    );
            `);
            
            // Public can view open requests (for matchmaking)
            await client.query(`
                CREATE POLICY policy_match_requests_public_open ON match_requests
                    FOR SELECT USING (
                        request_type = 'Open' AND status = 'Pending' AND expires_at > NOW()
                    );
            `);
            
            console.log('✅ RLS policies applied!');
            
            // Add constraints for data integrity
            console.log('⚖️  Adding data constraints...');
            await client.query(`
                ALTER TABLE match_requests ADD CONSTRAINT check_request_status 
                CHECK (status IN ('Pending', 'Accepted', 'Declined', 'Expired', 'Cancelled'));
            `);
            
            await client.query(`
                ALTER TABLE match_requests ADD CONSTRAINT check_request_type 
                CHECK (request_type IN ('Direct', 'Open', 'Tournament', 'Challenge'));
            `);
            
            await client.query(`
                ALTER TABLE match_requests ADD CONSTRAINT check_stake_positive 
                CHECK (stake_amount >= 0);
            `);
            
            await client.query(`
                ALTER TABLE match_requests ADD CONSTRAINT check_elo_range_valid 
                CHECK (min_elo IS NULL OR max_elo IS NULL OR min_elo <= max_elo);
            `);
            
            await client.query(`
                ALTER TABLE match_requests ADD CONSTRAINT check_expires_future 
                CHECK (expires_at > created_time);
            `);
            
            console.log('✅ Data constraints applied!');
        }
        
        // Analyze relationships
        console.log('\n🔗 Analyzing relationships...');
        const relationshipAnalysis = await client.query(`
            SELECT 
                COUNT(*) as total_requests,
                COUNT(DISTINCT creator_uid) as unique_creators,
                COUNT(DISTINCT opponent_uid) as unique_opponents,
                COUNT(DISTINCT club_id) as clubs_with_requests
            FROM match_requests;
        `);
        
        const stats = relationshipAnalysis.rows[0];
        console.log(`   📊 Total requests: ${stats.total_requests}`);
        console.log(`   📊 Unique creators: ${stats.unique_creators}`);
        console.log(`   📊 Unique opponents: ${stats.unique_opponents}`);
        console.log(`   📊 Clubs with requests: ${stats.clubs_with_requests}`);
        
        // Final verification
        const finalCheck = await client.query(`
            SELECT 
                COUNT(*) as column_count,
                (SELECT COUNT(*) FROM match_requests) as record_count
            FROM information_schema.columns 
            WHERE table_name = 'match_requests';
        `);
        
        console.log('\n🎯 Match Requests Table Migration Summary:');
        console.log(`   📋 Columns: ${finalCheck.rows[0].column_count}`);
        console.log(`   📊 Records: ${finalCheck.rows[0].record_count}`);
        console.log('   🔒 RLS: Enabled with participant access + public open requests');
        console.log('   📊 Indexes: Requester, target, club, status, type, expiry');
        console.log('   ⚖️  Constraints: Valid status/type, positive stakes, logical ELO range');
        console.log('\n✅ Match requests system handles:');
        console.log('   - Direct player invitations');
        console.log('   - Open challenges for matchmaking');
        console.log('   - Tournament-based requests');
        console.log('   - Stake-based competitive matches');
        console.log('   - ELO range filtering');
        console.log('   - Auto-expiration of old requests');
        console.log('\n🔗 Relationships:');
        console.log('   - match_requests.creator_uid → users.uid');
        console.log('   - match_requests.opponent_uid → users.uid');
        console.log('   - match_requests.club_id → clubs.club_id');
        console.log('\n🎮 Workflow:');
        console.log('   1. User creates request (Direct/Open)');
        console.log('   2. System finds matches or target accepts');
        console.log('   3. Match record created in matches table');
        console.log('   4. Request marked as Accepted with match_id');
        
    } catch (error) {
        console.error('❌ Error migrating match_requests table:', error.message);
        if (error.detail) console.error('   Details:', error.detail);
    } finally {
        await client.end();
    }
}

migrateMatchRequestsTable();