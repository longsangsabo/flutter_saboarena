#!/usr/bin/env node

const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

async function createAllTablesSimple() {
    const supabase = createClient(
        process.env.SUPABASE_URL,
        process.env.SUPABASE_SERVICE_ROLE_KEY
    );

    console.log('🚀 Creating all 10 additional tables directly...');

    const tables = [
        {
            name: 'user_relationships',
            sql: `CREATE TABLE IF NOT EXISTS user_relationships (
                relationship_id VARCHAR(255) PRIMARY KEY,
                follower_uid VARCHAR(255) NOT NULL,
                following_uid VARCHAR(255) NOT NULL,
                status VARCHAR(50) DEFAULT 'Active',
                created_time TIMESTAMPTZ DEFAULT NOW()
            )`
        },
        {
            name: 'rankings',
            sql: `CREATE TABLE IF NOT EXISTS rankings (
                ranking_id VARCHAR(255) PRIMARY KEY,
                rank_type VARCHAR(100) NOT NULL,
                position INTEGER NOT NULL,
                score INTEGER NOT NULL,
                period VARCHAR(50) NOT NULL,
                updated_time TIMESTAMPTZ DEFAULT NOW(),
                club_id VARCHAR(255),
                ranking_criteria VARCHAR(255),
                uid VARCHAR(255) NOT NULL
            )`
        },
        {
            name: 'user_settings',
            sql: `CREATE TABLE IF NOT EXISTS user_settings (
                notification_match BOOLEAN DEFAULT TRUE,
                notification_tournament BOOLEAN DEFAULT TRUE,
                privacy_profile VARCHAR(50) DEFAULT 'Public',
                language VARCHAR(10) DEFAULT 'vi',
                theme VARCHAR(20) DEFAULT 'Light',
                updated_time TIMESTAMPTZ DEFAULT NOW(),
                uid VARCHAR(255) PRIMARY KEY
            )`
        },
        {
            name: 'messages',
            sql: `CREATE TABLE IF NOT EXISTS messages (
                message_id VARCHAR(255) PRIMARY KEY,
                conversation_id VARCHAR(255) NOT NULL,
                sender_uid VARCHAR(255) NOT NULL,
                content TEXT NOT NULL,
                message_type VARCHAR(50) DEFAULT 'Text',
                is_read BOOLEAN DEFAULT FALSE,
                created_time TIMESTAMPTZ DEFAULT NOW()
            )`
        },
        {
            name: 'conversations',
            sql: `CREATE TABLE IF NOT EXISTS conversations (
                conversation_id VARCHAR(255) PRIMARY KEY,
                participant1_uid VARCHAR(255) NOT NULL,
                participant2_uid VARCHAR(255) NOT NULL,
                last_message TEXT,
                last_message_time TIMESTAMPTZ,
                created_time TIMESTAMPTZ DEFAULT NOW(),
                updated_time TIMESTAMPTZ DEFAULT NOW()
            )`
        },
        {
            name: 'club_reviews',
            sql: `CREATE TABLE IF NOT EXISTS club_reviews (
                review_id VARCHAR(255) PRIMARY KEY,
                club_id VARCHAR(255) NOT NULL,
                reviewer_uid VARCHAR(255) NOT NULL,
                rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
                comment TEXT,
                created_time TIMESTAMPTZ DEFAULT NOW(),
                status VARCHAR(50) DEFAULT 'Active'
            )`
        },
        {
            name: 'achievements',
            sql: `CREATE TABLE IF NOT EXISTS achievements (
                achievement_id VARCHAR(255) PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                description TEXT,
                badge_icon TEXT,
                requirement_type VARCHAR(100) NOT NULL,
                requirement_value INTEGER NOT NULL,
                spa_reward INTEGER DEFAULT 0,
                created_time TIMESTAMPTZ DEFAULT NOW()
            )`
        },
        {
            name: 'user_achievements',
            sql: `CREATE TABLE IF NOT EXISTS user_achievements (
                user_achievement_id VARCHAR(255) PRIMARY KEY,
                achievement_id VARCHAR(255) NOT NULL,
                progress INTEGER DEFAULT 0,
                is_completed BOOLEAN DEFAULT FALSE,
                completed_time TIMESTAMPTZ,
                created_time TIMESTAMPTZ DEFAULT NOW(),
                uid VARCHAR(255) NOT NULL
            )`
        },
        {
            name: 'match_ratings',
            sql: `CREATE TABLE IF NOT EXISTS match_ratings (
                rating_id VARCHAR(255) PRIMARY KEY,
                match_id VARCHAR(255) NOT NULL,
                rater_uid VARCHAR(255) NOT NULL,
                rated_uid VARCHAR(255) NOT NULL,
                rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
                comment TEXT,
                rating_type VARCHAR(50) DEFAULT 'Performance',
                created_time TIMESTAMPTZ DEFAULT NOW()
            )`
        },
        {
            name: 'club_staff',
            sql: `CREATE TABLE IF NOT EXISTS club_staff (
                staff_id VARCHAR(255) PRIMARY KEY,
                club_id VARCHAR(255) NOT NULL,
                role VARCHAR(50) NOT NULL,
                can_confirm_matches BOOLEAN DEFAULT FALSE,
                created_time TIMESTAMPTZ DEFAULT NOW(),
                uid VARCHAR(255) NOT NULL
            )`
        }
    ];

    try {
        // Create each table
        for (let i = 0; i < tables.length; i++) {
            const table = tables[i];
            console.log(`📋 Creating ${table.name} (${i + 1}/10)...`);
            
            // Use the rpc function to execute SQL
            const { error } = await supabase.rpc('exec_sql', { sql: table.sql });
            
            if (error) {
                console.error(`❌ Error creating ${table.name}:`, error.message);
            } else {
                console.log(`✅ ${table.name} created successfully`);
            }
        }

        // Check all tables
        console.log('\n🔍 Checking database tables...');
        const { data: tableList, error: listError } = await supabase.rpc('exec_sql', {
            sql: `SELECT table_name FROM information_schema.tables 
                  WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
                  ORDER BY table_name`
        });

        if (!listError && tableList) {
            console.log('\n📊 Complete database schema:');
            tableList.forEach((row, index) => {
                console.log(`   ${index + 1}. ${row.table_name}`);
            });
            console.log(`\n🎉 Total: ${tableList.length} tables in Sabo Arena database!`);
        } else {
            console.error('❌ Error listing tables:', listError?.message);
        }

    } catch (error) {
        console.error('❌ Unexpected error:', error.message);
    }
}

createAllTablesSimple();