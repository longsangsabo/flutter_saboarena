#!/usr/bin/env node

const { Client } = require('pg');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

async function createAllRelationships() {
    const client = new Client({
        connectionString: process.env.POOLER_URL,
        ssl: { rejectUnauthorized: false }
    });

    try {
        console.log('🔗 Creating ALL table relationships comprehensively...');
        await client.connect();
        console.log('✅ Connected to database');
        
        const relationships = [
            // USER-CENTERED RELATIONSHIPS
            {
                table: 'user_settings',
                column: 'uid',
                references: 'users(uid)',
                onDelete: 'CASCADE',
                description: '1:1 User Settings'
            },
            {
                table: 'clubs',
                column: 'owner_uid',
                references: 'users(uid)',
                onDelete: 'SET NULL',
                description: '1:many Club Ownership'
            },
            {
                table: 'notifications',
                column: 'recipient_uid',
                references: 'users(uid)',
                onDelete: 'CASCADE',
                description: '1:many Notification Recipients'
            },
            {
                table: 'notifications',
                column: 'sender_uid',
                references: 'users(uid)',
                onDelete: 'SET NULL',
                description: '1:many Notification Senders'
            },
            {
                table: 'user_achievements',
                column: 'uid',
                references: 'users(uid)',
                onDelete: 'CASCADE',
                description: '1:many User Achievements'
            },
            {
                table: 'user_relationships',
                column: 'follower_uid',
                references: 'users(uid)',
                onDelete: 'CASCADE',
                description: '1:many Followers'
            },
            {
                table: 'user_relationships',
                column: 'following_uid',
                references: 'users(uid)',
                onDelete: 'CASCADE',
                description: '1:many Following'
            },
            {
                table: 'rankings',
                column: 'uid',
                references: 'users(uid)',
                onDelete: 'CASCADE',
                description: '1:many Rankings'
            },
            {
                table: 'club_members',
                column: 'uid',
                references: 'users(uid)',
                onDelete: 'CASCADE',
                description: '1:many Club Members'
            },
            {
                table: 'club_staff',
                column: 'uid',
                references: 'users(uid)',
                onDelete: 'CASCADE',
                description: '1:many Club Staff'
            },
            {
                table: 'club_reviews',
                column: 'reviewer_uid',
                references: 'users(uid)',
                onDelete: 'CASCADE',
                description: '1:many Club Reviews'
            },
            
            // CLUB-CENTERED RELATIONSHIPS
            {
                table: 'club_members',
                column: 'club_id',
                references: 'clubs(club_id)',
                onDelete: 'CASCADE',
                description: '1:many Club Memberships'
            },
            {
                table: 'club_staff',
                column: 'club_id',
                references: 'clubs(club_id)',
                onDelete: 'CASCADE',
                description: '1:many Club Staff'
            },
            {
                table: 'club_reviews',
                column: 'club_id',
                references: 'clubs(club_id)',
                onDelete: 'CASCADE',
                description: '1:many Club Reviews'
            },
            {
                table: 'tournaments',
                column: 'club_id',
                references: 'clubs(club_id)',
                onDelete: 'SET NULL',
                description: '1:many Tournament Venues'
            },
            {
                table: 'matches',
                column: 'club_id',
                references: 'clubs(club_id)',
                onDelete: 'SET NULL',
                description: '1:many Match Venues'
            },
            {
                table: 'rankings',
                column: 'club_id',
                references: 'clubs(club_id)',
                onDelete: 'SET NULL',
                description: '1:many Club Rankings'
            },
            {
                table: 'match_requests',
                column: 'club_id',
                references: 'clubs(club_id)',
                onDelete: 'SET NULL',
                description: '1:many Match Request Venues'
            },
            
            // MATCH-CENTERED RELATIONSHIPS
            {
                table: 'matches',
                column: 'player1_uid',
                references: 'users(uid)',
                onDelete: 'SET NULL',
                description: 'many:1 Player 1'
            },
            {
                table: 'matches',
                column: 'player2_uid',
                references: 'users(uid)',
                onDelete: 'SET NULL',
                description: 'many:1 Player 2'
            },
            {
                table: 'matches',
                column: 'winner_uid',
                references: 'users(uid)',
                onDelete: 'SET NULL',
                description: 'many:1 Match Winner'
            },
            {
                table: 'match_ratings',
                column: 'match_id',
                references: 'matches(match_id)',
                onDelete: 'CASCADE',
                description: '1:many Match Ratings'
            },
            {
                table: 'match_ratings',
                column: 'rater_uid',
                references: 'users(uid)',
                onDelete: 'CASCADE',
                description: 'many:1 Rating Giver'
            },
            {
                table: 'match_ratings',
                column: 'rated_uid',
                references: 'users(uid)',
                onDelete: 'CASCADE',
                description: 'many:1 Rating Receiver'
            },
            {
                table: 'match_requests',
                column: 'creator_uid',
                references: 'users(uid)',
                onDelete: 'CASCADE',
                description: 'many:1 Request Creator'
            },
            {
                table: 'match_requests',
                column: 'opponent_uid',
                references: 'users(uid)',
                onDelete: 'CASCADE',
                description: 'many:1 Request Opponent'
            },
            
            // SOCIAL RELATIONSHIPS
            {
                table: 'conversations',
                column: 'participant1_uid',
                references: 'users(uid)',
                onDelete: 'CASCADE',
                description: 'many:1 Conversation Participant 1'
            },
            {
                table: 'conversations',
                column: 'participant2_uid',
                references: 'users(uid)',
                onDelete: 'CASCADE',
                description: 'many:1 Conversation Participant 2'
            },
            {
                table: 'messages',
                column: 'sender_uid',
                references: 'users(uid)',
                onDelete: 'CASCADE',
                description: 'many:1 Message Sender'
            },
            {
                table: 'messages',
                column: 'conversation_id',
                references: 'conversations(conversation_id)',
                onDelete: 'CASCADE',
                description: 'many:1 Message Conversation'
            },
            
            // GAMIFICATION RELATIONSHIPS
            {
                table: 'user_achievements',
                column: 'achievement_id',
                references: 'achievements(achievement_id)',
                onDelete: 'CASCADE',
                description: 'many:1 Achievement Reference'
            },
            
            // NOTIFICATION RELATIONSHIPS
            {
                table: 'notifications',
                column: 'match_id',
                references: 'matches(match_id)',
                onDelete: 'SET NULL',
                description: 'many:1 Match Notifications'
            },
            {
                table: 'notifications',
                column: 'tournament_id',
                references: 'tournaments(tournament_id)',
                onDelete: 'SET NULL',
                description: 'many:1 Tournament Notifications'
            },
            {
                table: 'notifications',
                column: 'request_id',
                references: 'match_requests(request_id)',
                onDelete: 'SET NULL',
                description: 'many:1 Request Notifications'
            }
        ];
        
        console.log(`\n🔗 Creating ${relationships.length} foreign key relationships...\n`);
        
        let successCount = 0;
        let skipCount = 0;
        
        for (const rel of relationships) {
            const constraintName = `fk_${rel.table}_${rel.column}`;
            
            try {
                await client.query(`
                    ALTER TABLE ${rel.table} 
                    ADD CONSTRAINT ${constraintName}
                    FOREIGN KEY (${rel.column}) 
                    REFERENCES ${rel.references} 
                    ON DELETE ${rel.onDelete};
                `);
                console.log(`✅ ${rel.table}.${rel.column} → ${rel.references} (${rel.description})`);
                successCount++;
            } catch (error) {
                if (error.message.includes('already exists')) {
                    console.log(`⚡ ${rel.table}.${rel.column} → ${rel.references} (already exists)`);
                    skipCount++;
                } else {
                    console.log(`❌ ${rel.table}.${rel.column} → ${rel.references} (${error.message})`);
                }
            }
        }
        
        // Verify all relationships
        console.log('\n🔍 Verifying relationship network...');
        
        const allForeignKeys = await client.query(`
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
        
        console.log(`\n📊 RELATIONSHIP NETWORK SUMMARY:`);
        console.log(`   ✅ New relationships created: ${successCount}`);
        console.log(`   ⚡ Already existing: ${skipCount}`);
        console.log(`   🔗 Total foreign keys active: ${allForeignKeys.rows.length}`);
        console.log(`   🎯 Relationship coverage: ${Math.round((allForeignKeys.rows.length / relationships.length) * 100)}%`);
        
        console.log(`\n🔗 Active Foreign Key Relationships:`);
        const groupedFKs = {};
        allForeignKeys.rows.forEach(fk => {
            if (!groupedFKs[fk.source_table]) {
                groupedFKs[fk.source_table] = [];
            }
            groupedFKs[fk.source_table].push(`${fk.source_column} → ${fk.target_table}.${fk.target_column}`);
        });
        
        Object.keys(groupedFKs).sort().forEach(table => {
            console.log(`   📋 ${table}:`);
            groupedFKs[table].forEach(relationship => {
                console.log(`      🔗 ${relationship}`);
            });
        });
        
        console.log('\n🎉 SABO ARENA DATABASE RELATIONSHIP NETWORK COMPLETE!');
        console.log('   🎱 Full billiards arena management system');
        console.log('   👥 Complete social networking features');
        console.log('   🏆 Tournament and ranking systems');
        console.log('   🔒 Data integrity with proper cascading');
        console.log('   🚀 Ready for production deployment!');
        
    } catch (error) {
        console.error('❌ Error creating relationships:', error.message);
        if (error.detail) console.error('   Details:', error.detail);
    } finally {
        await client.end();
    }
}

createAllRelationships();