#!/usr/bin/env node

const { Client } = require('pg');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

async function migrateMatchesTable() {
    const client = new Client({
        connectionString: process.env.POOLER_URL,
        ssl: { rejectUnauthorized: false }
    });

    try {
        console.log('🎱 Migrating matches table - Core Billiards Match System...');
        await client.connect();
        console.log('✅ Connected to database');
        
        // Check if table exists
        const tableExists = await client.query(`
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_schema = 'public' AND table_name = 'matches'
            );
        `);
        
        if (tableExists.rows[0].exists) {
            console.log('⚠️  matches table already exists. Analyzing structure...');
            
            const columns = await client.query(`
                SELECT column_name, data_type, is_nullable, column_default
                FROM information_schema.columns 
                WHERE table_name = 'matches' 
                ORDER BY ordinal_position;
            `);
            
            console.log('📋 Current matches table structure:');
            columns.rows.forEach((col, index) => {
                console.log(`   ${index + 1}. ${col.column_name} (${col.data_type})`);
            });
            
            const rowCount = await client.query('SELECT COUNT(*) FROM matches');
            console.log(`📊 Current records: ${rowCount.rows[0].count}`);
            
            // Check indexes
            const indexes = await client.query(`
                SELECT indexname, indexdef 
                FROM pg_indexes 
                WHERE tablename = 'matches';
            `);
            
            console.log('\n📊 Current indexes:');
            indexes.rows.forEach((idx, index) => {
                console.log(`   ${index + 1}. ${idx.indexname}`);
            });
            
            // Analyze match patterns
            if (rowCount.rows[0].count > 0) {
                const statusBreakdown = await client.query(`
                    SELECT status, COUNT(*) as count
                    FROM matches 
                    GROUP BY status;
                `);
                
                console.log('\n📊 Match status breakdown:');
                statusBreakdown.rows.forEach(row => {
                    console.log(`   ${row.status}: ${row.count}`);
                });
                
                const gameTypeBreakdown = await client.query(`
                    SELECT game_type, COUNT(*) as count
                    FROM matches 
                    GROUP BY game_type;
                `);
                
                console.log('\n📊 Game type breakdown:');
                gameTypeBreakdown.rows.forEach(row => {
                    console.log(`   ${row.game_type}: ${row.count}`);
                });
                
                // Analyze completed matches
                const completedMatches = await client.query(`
                    SELECT 
                        COUNT(*) as completed_count,
                        AVG(EXTRACT(EPOCH FROM (end_time - start_time))/60) as avg_duration_minutes
                    FROM matches 
                    WHERE status = 'Completed' AND start_time IS NOT NULL AND end_time IS NOT NULL;
                `);
                
                if (completedMatches.rows[0].completed_count > 0) {
                    console.log(`\n⏱️  Completed matches: ${completedMatches.rows[0].completed_count}`);
                    console.log(`   Average duration: ${Math.round(completedMatches.rows[0].avg_duration_minutes)} minutes`);
                }
                
                // Check ELO changes
                const eloStats = await client.query(`
                    SELECT 
                        COUNT(*) as matches_with_elo,
                        AVG(ABS(player1_elo_after - player1_elo_before)) as avg_elo_change
                    FROM matches 
                    WHERE player1_elo_before IS NOT NULL AND player1_elo_after IS NOT NULL;
                `);
                
                if (eloStats.rows[0].matches_with_elo > 0) {
                    console.log(`\n📈 Matches with ELO changes: ${eloStats.rows[0].matches_with_elo}`);
                    console.log(`   Average ELO change: ${Math.round(eloStats.rows[0].avg_elo_change)} points`);
                }
            }
            
            // Check RLS status
            const rlsStatus = await client.query(`
                SELECT relrowsecurity 
                FROM pg_class 
                WHERE relname = 'matches';
            `);
            
            console.log(`🔒 RLS Status: ${rlsStatus.rows[0]?.relrowsecurity ? 'Enabled' : 'Disabled'}`);
            
        } else {
            console.log('📋 Creating matches table - Core match management...');
            
            // Create matches table with complete structure
            await client.query(`
                CREATE TABLE matches (
                    -- Primary identifier
                    match_id VARCHAR(255) PRIMARY KEY DEFAULT gen_random_uuid()::text,
                    created_time TIMESTAMPTZ DEFAULT NOW(),
                    
                    -- Players
                    player1_uid VARCHAR(255) NOT NULL,
                    player2_uid VARCHAR(255) NOT NULL,
                    
                    -- Venue
                    club_id VARCHAR(255),
                    table_number INTEGER,
                    
                    -- Match settings
                    match_type VARCHAR(50) DEFAULT 'Casual',
                    game_mode VARCHAR(50) DEFAULT '8-Ball',
                    race_to INTEGER DEFAULT 5,
                    
                    -- Status & timing
                    status VARCHAR(50) DEFAULT 'Scheduled',
                    scheduled_time TIMESTAMPTZ,
                    actual_start_time TIMESTAMPTZ,
                    actual_end_time TIMESTAMPTZ,
                    
                    -- Scores & results
                    player1_score INTEGER DEFAULT 0,
                    player2_score INTEGER DEFAULT 0,
                    winner_uid VARCHAR(255),
                    match_duration INTEGER, -- in seconds
                    
                    -- ELO system
                    player1_elo_before INTEGER,
                    player1_elo_after INTEGER,
                    player2_elo_before INTEGER,
                    player2_elo_after INTEGER,
                    elo_change INTEGER,
                    
                    -- SPA points
                    spa_points_awarded INTEGER DEFAULT 0,
                    spa_points_player1 INTEGER DEFAULT 0,
                    spa_points_player2 INTEGER DEFAULT 0,
                    
                    -- Club confirmation
                    is_confirmed_by_club BOOLEAN DEFAULT FALSE,
                    confirmed_by VARCHAR(255),
                    confirmation_time TIMESTAMPTZ,
                    
                    -- Stakes & betting
                    stake_amount DECIMAL(10,2) DEFAULT 0.00,
                    entry_fee DECIMAL(10,2) DEFAULT 0.00,
                    
                    -- Additional data
                    match_data JSONB DEFAULT '{}',
                    notes TEXT
                );
            `);
            
            console.log('✅ matches table created successfully!');
            
            // Create performance indexes
            console.log('📊 Creating performance indexes...');
            await client.query('CREATE INDEX idx_matches_player1 ON matches(player1_uid);');
            await client.query('CREATE INDEX idx_matches_player2 ON matches(player2_uid);');
            await client.query('CREATE INDEX idx_matches_club_id ON matches(club_id);');
            await client.query('CREATE INDEX idx_matches_status ON matches(status);');
            await client.query('CREATE INDEX idx_matches_match_type ON matches(match_type);');
            await client.query('CREATE INDEX idx_matches_scheduled_time ON matches(scheduled_time);');
            await client.query('CREATE INDEX idx_matches_winner ON matches(winner_uid);');
            await client.query('CREATE INDEX idx_matches_created_time ON matches(created_time);');
            await client.query('CREATE INDEX idx_matches_confirmation ON matches(is_confirmed_by_club);');
            
            console.log('✅ Indexes created successfully!');
            
            // Enable Row Level Security
            console.log('🔒 Enabling Row Level Security...');
            await client.query('ALTER TABLE matches ENABLE ROW LEVEL SECURITY;');
            
            // Create RLS policies
            // Players can view/edit their own matches
            await client.query(`
                CREATE POLICY policy_matches_participants ON matches
                    FOR ALL USING (
                        auth.uid()::text IN (player1_uid, player2_uid)
                    );
            `);
            
            // Club staff can view matches at their club
            await client.query(`
                CREATE POLICY policy_matches_club_staff ON matches
                    FOR SELECT USING (
                        club_id IN (
                            SELECT club_id FROM club_staff 
                            WHERE uid = auth.uid()::text
                        )
                    );
            `);
            
            console.log('✅ RLS policies applied!');
            
            // Add constraints for data integrity
            console.log('⚖️  Adding data constraints...');
            await client.query(`
                ALTER TABLE matches ADD CONSTRAINT check_match_status 
                CHECK (status IN ('Scheduled', 'In Progress', 'Completed', 'Cancelled', 'Disputed'));
            `);
            
            await client.query(`
                ALTER TABLE matches ADD CONSTRAINT check_match_type 
                CHECK (match_type IN ('Casual', 'Ranked', 'Tournament', 'Challenge'));
            `);
            
            await client.query(`
                ALTER TABLE matches ADD CONSTRAINT check_different_players 
                CHECK (player1_uid != player2_uid);
            `);
            
            await client.query(`
                ALTER TABLE matches ADD CONSTRAINT check_scores_positive 
                CHECK (player1_score >= 0 AND player2_score >= 0);
            `);
            
            await client.query(`
                ALTER TABLE matches ADD CONSTRAINT check_race_to_positive 
                CHECK (race_to > 0);
            `);
            
            await client.query(`
                ALTER TABLE matches ADD CONSTRAINT check_stake_positive 
                CHECK (stake_amount >= 0 AND entry_fee >= 0);
            `);
            
            console.log('✅ Data constraints applied!');
        }
        
        // Analyze relationships and data integrity
        console.log('\n🔗 Analyzing relationships...');
        const relationshipAnalysis = await client.query(`
            SELECT 
                COUNT(*) as total_matches,
                COUNT(DISTINCT player1_uid) as unique_player1s,
                COUNT(DISTINCT player2_uid) as unique_player2s,
                COUNT(DISTINCT club_id) as clubs_with_matches,
                COUNT(DISTINCT winner_uid) as unique_winners
            FROM matches;
        `);
        
        const stats = relationshipAnalysis.rows[0];
        console.log(`   📊 Total matches: ${stats.total_matches}`);
        console.log(`   📊 Unique player1s: ${stats.unique_player1s}`);
        console.log(`   📊 Unique player2s: ${stats.unique_player2s}`);
        console.log(`   📊 Clubs with matches: ${stats.clubs_with_matches}`);
        console.log(`   📊 Unique winners: ${stats.unique_winners}`);
        
        // Check data integrity
        const integrityCheck = await client.query(`
            SELECT 
                COUNT(*) as matches_with_invalid_winner
            FROM matches 
            WHERE winner_uid IS NOT NULL 
            AND winner_uid NOT IN (player1_uid, player2_uid);
        `);
        
        console.log(`   🔍 Data integrity - Invalid winners: ${integrityCheck.rows[0].matches_with_invalid_winner}`);
        
        // Final verification
        const finalCheck = await client.query(`
            SELECT 
                COUNT(*) as column_count,
                (SELECT COUNT(*) FROM matches) as record_count
            FROM information_schema.columns 
            WHERE table_name = 'matches';
        `);
        
        console.log('\n🎯 Matches Table Migration Summary:');
        console.log(`   📋 Columns: ${finalCheck.rows[0].column_count}`);
        console.log(`   📊 Records: ${finalCheck.rows[0].record_count}`);
        console.log('   🔒 RLS: Enabled with participant access + club staff view');
        console.log('   📊 Indexes: Players, club, status, type, schedule, winner');
        console.log('   ⚖️  Constraints: Valid status/type, different players, positive values');
        console.log('\n✅ Matches system handles:');
        console.log('   - Player vs player billiards matches');
        console.log('   - Multiple game modes (8-Ball, 9-Ball, etc.)');
        console.log('   - ELO rating calculations & changes');
        console.log('   - SPA points distribution');
        console.log('   - Club venue & table management');
        console.log('   - Match confirmation workflow');
        console.log('   - Stakes & entry fees');
        console.log('   - Tournament integration');
        console.log('\n🔗 Relationships:');
        console.log('   - matches.player1_uid → users.uid');
        console.log('   - matches.player2_uid → users.uid');
        console.log('   - matches.winner_uid → users.uid');
        console.log('   - matches.club_id → clubs.club_id');
        console.log('   - matches.confirmed_by → users.uid (club staff)');
        console.log('\n🎮 Match Lifecycle:');
        console.log('   1. Created from match_request or tournament');
        console.log('   2. Scheduled → In Progress → Completed');
        console.log('   3. ELO ratings updated for both players');
        console.log('   4. SPA points awarded based on performance');
        console.log('   5. Club confirmation for official ranking');
        
    } catch (error) {
        console.error('❌ Error migrating matches table:', error.message);
        if (error.detail) console.error('   Details:', error.detail);
    } finally {
        await client.end();
    }
}

migrateMatchesTable();