#!/usr/bin/env node

const { Client } = require('pg');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

async function analyzeTableRelationships() {
    const client = new Client({
        connectionString: process.env.POOLER_URL,
        ssl: { rejectUnauthorized: false }
    });

    try {
        console.log('🔗 Analyzing existing table relationships...');
        await client.connect();
        console.log('✅ Connected to database');
        
        // Get all tables
        const tables = await client.query(`
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
            ORDER BY table_name;
        `);
        
        console.log(`\n📊 Found ${tables.rows.length} tables in database:`);
        tables.rows.forEach((table, index) => {
            console.log(`   ${index + 1}. ${table.table_name}`);
        });
        
        // Check existing foreign keys
        const foreignKeys = await client.query(`
            SELECT 
                tc.table_name AS source_table,
                kcu.column_name AS source_column,
                ccu.table_name AS target_table,
                ccu.column_name AS target_column,
                tc.constraint_name
            FROM information_schema.table_constraints AS tc 
            JOIN information_schema.key_column_usage AS kcu
                ON tc.constraint_name = kcu.constraint_name
                AND tc.table_schema = kcu.table_schema
            JOIN information_schema.constraint_column_usage AS ccu
                ON ccu.constraint_name = tc.constraint_name
                AND ccu.table_schema = tc.table_schema
            WHERE tc.constraint_type = 'FOREIGN KEY'
            ORDER BY tc.table_name, kcu.column_name;
        `);
        
        console.log(`\n🔗 Current foreign key relationships: ${foreignKeys.rows.length}`);
        if (foreignKeys.rows.length > 0) {
            foreignKeys.rows.forEach(fk => {
                console.log(`   ${fk.source_table}.${fk.source_column} → ${fk.target_table}.${fk.target_column}`);
            });
        } else {
            console.log('   ⚠️  No foreign key relationships found!');
        }
        
        // Check columns that look like foreign keys (ending with _id or _uid)
        const potentialFKColumns = await client.query(`
            SELECT 
                table_name, 
                column_name, 
                data_type
            FROM information_schema.columns 
            WHERE table_schema = 'public' 
            AND (column_name LIKE '%_id' OR column_name LIKE '%_uid')
            AND column_name != 'notification_id'
            AND column_name != 'achievement_id' 
            AND column_name != 'conversation_id'
            AND column_name != 'message_id'
            ORDER BY table_name, column_name;
        `);
        
        console.log(`\n🎯 Potential foreign key columns found: ${potentialFKColumns.rows.length}`);
        const tableGroups = {};
        potentialFKColumns.rows.forEach(col => {
            if (!tableGroups[col.table_name]) {
                tableGroups[col.table_name] = [];
            }
            tableGroups[col.table_name].push(col.column_name);
        });
        
        Object.keys(tableGroups).forEach(tableName => {
            console.log(`   📋 ${tableName}:`);
            tableGroups[tableName].forEach(column => {
                console.log(`      - ${column}`);
            });
        });
        
        // Analyze relationship patterns needed
        console.log('\n🏗️  REQUIRED RELATIONSHIP MAPPING:');
        
        console.log('\n👤 USER-CENTERED RELATIONSHIPS:');
        console.log('   users.uid → user_settings.uid (1:1)');
        console.log('   users.uid → clubs.owner_uid (1:many)');
        console.log('   users.uid → notifications.recipient_uid (1:many)');
        console.log('   users.uid → user_achievements.uid (1:many)');
        console.log('   users.uid → user_relationships.follower_uid (1:many)');
        console.log('   users.uid → user_relationships.following_uid (1:many)');
        console.log('   users.uid → rankings.uid (1:many)');
        
        console.log('\n🏢 CLUB-CENTERED RELATIONSHIPS:');
        console.log('   clubs.club_id → club_members.club_id (1:many)');
        console.log('   clubs.club_id → club_staff.club_id (1:many)');
        console.log('   clubs.club_id → club_reviews.club_id (1:many)');
        console.log('   clubs.club_id → tournaments.club_id (1:many)');
        console.log('   clubs.club_id → matches.club_id (1:many)');
        
        console.log('\n🎱 MATCH-CENTERED RELATIONSHIPS:');
        console.log('   matches.match_id → match_ratings.match_id (1:many)');
        console.log('   matches.player1_uid → users.uid (many:1)');
        console.log('   matches.player2_uid → users.uid (many:1)');
        console.log('   match_requests.match_id → matches.match_id (1:1)');
        
        console.log('\n🏆 TOURNAMENT RELATIONSHIPS:');
        console.log('   tournaments.tournament_id → notifications.tournament_id (1:many)');
        
        console.log('\n💬 SOCIAL RELATIONSHIPS:');
        console.log('   conversations.participant1_uid → users.uid (many:1)');
        console.log('   conversations.participant2_uid → users.uid (many:1)');
        console.log('   messages.conversation_id → conversations.conversation_id (many:1)');
        console.log('   messages.sender_uid → users.uid (many:1)');
        
        console.log('\n🎮 GAMIFICATION RELATIONSHIPS:');
        console.log('   user_achievements.achievement_id → achievements.achievement_id (many:1)');
        
        console.log('\n📊 RELATIONSHIP SUMMARY:');
        console.log('   🔗 Total relationships needed: ~25-30 foreign keys');
        console.log('   🎯 Central tables: users, clubs, matches');
        console.log('   📈 Most referenced: users.uid (15+ references)');
        console.log('   🏢 Club ecosystem: 5 related tables');
        console.log('   💬 Social network: 4 interconnected tables');
        
    } catch (error) {
        console.error('❌ Error during analysis:', error.message);
    } finally {
        await client.end();
    }
}

analyzeTableRelationships();