#!/usr/bin/env node

const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
require('dotenv').config();

async function createAllTables() {
    const supabase = createClient(
        process.env.SUPABASE_URL,
        process.env.SUPABASE_SERVICE_ROLE_KEY
    );

    console.log('🚀 Creating all 10 additional tables with Supabase client...');

    try {
        // Read the migration SQL
        const migrationSQL = fs.readFileSync('migrations/010_create_additional_tables.sql', 'utf8');
        
        // Split into individual statements to avoid issues
        const statements = migrationSQL
            .split(';')
            .map(stmt => stmt.trim())
            .filter(stmt => stmt && !stmt.startsWith('--') && !stmt.startsWith('BEGIN') && !stmt.startsWith('COMMIT'));

        console.log(`📄 Found ${statements.length} SQL statements to execute`);

        // Execute key table creation statements
        const tableStatements = [
            // 1. User relationships
            `CREATE TABLE IF NOT EXISTS user_relationships (
                relationship_id VARCHAR(255) PRIMARY KEY,
                follower_uid VARCHAR(255) NOT NULL,
                following_uid VARCHAR(255) NOT NULL,
                status VARCHAR(50) DEFAULT 'Active',
                created_time TIMESTAMPTZ DEFAULT NOW()
            )`,
            
            // 2. Rankings
            `CREATE TABLE IF NOT EXISTS rankings (
                ranking_id VARCHAR(255) PRIMARY KEY,
                rank_type VARCHAR(100) NOT NULL,
                position INTEGER NOT NULL,
                score INTEGER NOT NULL,
                period VARCHAR(50) NOT NULL,
                updated_time TIMESTAMPTZ DEFAULT NOW(),
                club_id VARCHAR(255),
                ranking_criteria VARCHAR(255),
                uid VARCHAR(255) NOT NULL
            )`,
            
            // 3. User settings
            `CREATE TABLE IF NOT EXISTS user_settings (
                notification_match BOOLEAN DEFAULT TRUE,
                notification_tournament BOOLEAN DEFAULT TRUE,
                privacy_profile VARCHAR(50) DEFAULT 'Public',
                language VARCHAR(10) DEFAULT 'vi',
                theme VARCHAR(20) DEFAULT 'Light',
                updated_time TIMESTAMPTZ DEFAULT NOW(),
                uid VARCHAR(255) PRIMARY KEY
            )`,
            
            // 4. Messages
            `CREATE TABLE IF NOT EXISTS messages (
                message_id VARCHAR(255) PRIMARY KEY,
                conversation_id VARCHAR(255) NOT NULL,
                sender_uid VARCHAR(255) NOT NULL,
                content TEXT NOT NULL,
                message_type VARCHAR(50) DEFAULT 'Text',
                is_read BOOLEAN DEFAULT FALSE,
                created_time TIMESTAMPTZ DEFAULT NOW()
            )`,
            
            // 5. Conversations
            `CREATE TABLE IF NOT EXISTS conversations (
                conversation_id VARCHAR(255) PRIMARY KEY,
                participant1_uid VARCHAR(255) NOT NULL,
                participant2_uid VARCHAR(255) NOT NULL,
                last_message TEXT,
                last_message_time TIMESTAMPTZ,
                created_time TIMESTAMPTZ DEFAULT NOW(),
                updated_time TIMESTAMPTZ DEFAULT NOW()
            )`,
            
            // 6. Club reviews
            `CREATE TABLE IF NOT EXISTS club_reviews (
                review_id VARCHAR(255) PRIMARY KEY,
                club_id VARCHAR(255) NOT NULL,
                reviewer_uid VARCHAR(255) NOT NULL,
                rating INTEGER NOT NULL,
                comment TEXT,
                created_time TIMESTAMPTZ DEFAULT NOW(),
                status VARCHAR(50) DEFAULT 'Active'
            )`,
            
            // 7. Achievements
            `CREATE TABLE IF NOT EXISTS achievements (
                achievement_id VARCHAR(255) PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                description TEXT,
                badge_icon TEXT,
                requirement_type VARCHAR(100) NOT NULL,
                requirement_value INTEGER NOT NULL,
                spa_reward INTEGER DEFAULT 0,
                created_time TIMESTAMPTZ DEFAULT NOW()
            )`,
            
            // 8. User achievements
            `CREATE TABLE IF NOT EXISTS user_achievements (
                user_achievement_id VARCHAR(255) PRIMARY KEY,
                achievement_id VARCHAR(255) NOT NULL,
                progress INTEGER DEFAULT 0,
                is_completed BOOLEAN DEFAULT FALSE,
                completed_time TIMESTAMPTZ,
                created_time TIMESTAMPTZ DEFAULT NOW(),
                uid VARCHAR(255) NOT NULL
            )`,
            
            // 9. Match ratings
            `CREATE TABLE IF NOT EXISTS match_ratings (
                rating_id VARCHAR(255) PRIMARY KEY,
                match_id VARCHAR(255) NOT NULL,
                rater_uid VARCHAR(255) NOT NULL,
                rated_uid VARCHAR(255) NOT NULL,
                rating INTEGER NOT NULL,
                comment TEXT,
                rating_type VARCHAR(50) DEFAULT 'Performance',
                created_time TIMESTAMPTZ DEFAULT NOW()
            )`,
            
            // 10. Club staff
            `CREATE TABLE IF NOT EXISTS club_staff (
                staff_id VARCHAR(255) PRIMARY KEY,
                club_id VARCHAR(255) NOT NULL,
                role VARCHAR(50) NOT NULL,
                can_confirm_matches BOOLEAN DEFAULT FALSE,
                created_time TIMESTAMPTZ DEFAULT NOW(),
                uid VARCHAR(255) NOT NULL
            )`
        ];

        // Execute each table creation
        for (let i = 0; i < tableStatements.length; i++) {
            const sql = tableStatements[i];
            console.log(`📋 Creating table ${i + 1}/10...`);
            
            const { error } = await supabase.rpc('exec_sql', { sql });
            
            if (error) {
                console.error(`❌ Error creating table ${i + 1}:`, error.message);
            } else {
                console.log(`✅ Table ${i + 1} created successfully`);
            }
        }

        // Check all tables
        const { data: tables, error: tablesError } = await supabase.rpc('exec_sql', {
            sql: `SELECT table_name FROM information_schema.tables 
                  WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
                  ORDER BY table_name`
        });

        if (!tablesError && tables) {
            console.log('\n📊 Complete database schema:');
            tables.forEach(row => {
                console.log(`   ✅ ${row.table_name}`);
            });
            console.log(`\n🎉 Total: ${tables.length} tables in Sabo Arena database!`);
        }

    } catch (error) {
        console.error('❌ Error:', error.message);
    }
}

createAllTables();