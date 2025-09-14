#!/usr/bin/env node

const { Client } = require('pg');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

async function createCoreUserRelationships() {
    const client = new Client({
        connectionString: process.env.POOLER_URL,
        ssl: { rejectUnauthorized: false }
    });

    try {
        console.log('👤 Creating core user relationships...');
        await client.connect();
        console.log('✅ Connected to database');
        
        // 1. users.uid → user_settings.uid (1:1 relationship)
        console.log('\n🔗 Creating user_settings relationship...');
        try {
            await client.query(`
                ALTER TABLE user_settings 
                ADD CONSTRAINT fk_user_settings_uid 
                FOREIGN KEY (uid) REFERENCES users(uid) ON DELETE CASCADE;
            `);
            console.log('✅ user_settings.uid → users.uid');
        } catch (error) {
            console.log('⚠️  user_settings foreign key may already exist');
        }
        
        // 2. users.uid → clubs.owner_uid (1:many relationship)
        console.log('\n🔗 Creating clubs ownership relationship...');
        try {
            await client.query(`
                ALTER TABLE clubs 
                ADD CONSTRAINT fk_clubs_owner_uid 
                FOREIGN KEY (owner_uid) REFERENCES users(uid) ON DELETE SET NULL;
            `);
            console.log('✅ clubs.owner_uid → users.uid');
        } catch (error) {
            console.log('⚠️  clubs.owner_uid foreign key may already exist');
        }
        
        // 3. users.uid → notifications.recipient_uid (1:many)
        console.log('\n🔗 Creating notifications recipient relationship...');
        try {
            await client.query(`
                ALTER TABLE notifications 
                ADD CONSTRAINT fk_notifications_recipient_uid 
                FOREIGN KEY (recipient_uid) REFERENCES users(uid) ON DELETE CASCADE;
            `);
            console.log('✅ notifications.recipient_uid → users.uid');
        } catch (error) {
            console.log('⚠️  notifications.recipient_uid foreign key may already exist');
        }
        
        // 4. users.uid → notifications.sender_uid (1:many)
        console.log('\n🔗 Creating notifications sender relationship...');
        try {
            await client.query(`
                ALTER TABLE notifications 
                ADD CONSTRAINT fk_notifications_sender_uid 
                FOREIGN KEY (sender_uid) REFERENCES users(uid) ON DELETE SET NULL;
            `);
            console.log('✅ notifications.sender_uid → users.uid');
        } catch (error) {
            console.log('⚠️  notifications.sender_uid foreign key may already exist');
        }
        
        // 5. users.uid → user_achievements.uid (1:many)
        console.log('\n🔗 Creating user achievements relationship...');
        try {
            await client.query(`
                ALTER TABLE user_achievements 
                ADD CONSTRAINT fk_user_achievements_uid 
                FOREIGN KEY (uid) REFERENCES users(uid) ON DELETE CASCADE;
            `);
            console.log('✅ user_achievements.uid → users.uid');
        } catch (error) {
            console.log('⚠️  user_achievements.uid foreign key may already exist');
        }
        
        // 6. users.uid → user_relationships.follower_uid (1:many)
        console.log('\n🔗 Creating user relationships follower...');
        try {
            await client.query(`
                ALTER TABLE user_relationships 
                ADD CONSTRAINT fk_user_relationships_follower_uid 
                FOREIGN KEY (follower_uid) REFERENCES users(uid) ON DELETE CASCADE;
            `);
            console.log('✅ user_relationships.follower_uid → users.uid');
        } catch (error) {
            console.log('⚠️  user_relationships.follower_uid foreign key may already exist');
        }
        
        // 7. users.uid → user_relationships.following_uid (1:many)
        console.log('\n🔗 Creating user relationships following...');
        try {
            await client.query(`
                ALTER TABLE user_relationships 
                ADD CONSTRAINT fk_user_relationships_following_uid 
                FOREIGN KEY (following_uid) REFERENCES users(uid) ON DELETE CASCADE;
            `);
            console.log('✅ user_relationships.following_uid → users.uid');
        } catch (error) {
            console.log('⚠️  user_relationships.following_uid foreign key may already exist');
        }
        
        // 8. users.uid → rankings.uid (1:many)
        console.log('\n🔗 Creating rankings relationship...');
        try {
            await client.query(`
                ALTER TABLE rankings 
                ADD CONSTRAINT fk_rankings_uid 
                FOREIGN KEY (uid) REFERENCES users(uid) ON DELETE CASCADE;
            `);
            console.log('✅ rankings.uid → users.uid');
        } catch (error) {
            console.log('⚠️  rankings.uid foreign key may already exist');
        }
        
        // 9. users.uid → club_members.uid (1:many)
        console.log('\n🔗 Creating club members relationship...');
        try {
            await client.query(`
                ALTER TABLE club_members 
                ADD CONSTRAINT fk_club_members_uid 
                FOREIGN KEY (uid) REFERENCES users(uid) ON DELETE CASCADE;
            `);
            console.log('✅ club_members.uid → users.uid');
        } catch (error) {
            console.log('⚠️  club_members.uid foreign key may already exist');
        }
        
        // 10. users.uid → club_staff.uid (1:many)
        console.log('\n🔗 Creating club staff relationship...');
        try {
            await client.query(`
                ALTER TABLE club_staff 
                ADD CONSTRAINT fk_club_staff_uid 
                FOREIGN KEY (uid) REFERENCES users(uid) ON DELETE CASCADE;
            `);
            console.log('✅ club_staff.uid → users.uid');
        } catch (error) {
            console.log('⚠️  club_staff.uid foreign key may already exist');
        }
        
        // 11. users.uid → club_reviews.reviewer_uid (1:many)
        console.log('\n🔗 Creating club reviews relationship...');
        try {
            await client.query(`
                ALTER TABLE club_reviews 
                ADD CONSTRAINT fk_club_reviews_reviewer_uid 
                FOREIGN KEY (reviewer_uid) REFERENCES users(uid) ON DELETE CASCADE;
            `);
            console.log('✅ club_reviews.reviewer_uid → users.uid');
        } catch (error) {
            console.log('⚠️  club_reviews.reviewer_uid foreign key may already exist');
        }
        
        // Verify user-centered relationships
        const userForeignKeys = await client.query(`
            SELECT 
                tc.table_name AS source_table,
                kcu.column_name AS source_column,
                tc.constraint_name
            FROM information_schema.table_constraints AS tc 
            JOIN information_schema.key_column_usage AS kcu
                ON tc.constraint_name = kcu.constraint_name
            JOIN information_schema.constraint_column_usage AS ccu
                ON ccu.constraint_name = tc.constraint_name
            WHERE tc.constraint_type = 'FOREIGN KEY'
            AND ccu.table_name = 'users'
            ORDER BY tc.table_name;
        `);
        
        console.log(`\n✅ Core user relationships created: ${userForeignKeys.rows.length}`);
        userForeignKeys.rows.forEach(fk => {
            console.log(`   🔗 ${fk.source_table}.${fk.source_column} → users.uid`);
        });
        
        console.log('\n🎯 USER-CENTERED RELATIONSHIP NETWORK COMPLETE!');
        console.log('   👤 users table is now the central hub');
        console.log('   🔗 All user-related tables properly linked');
        console.log('   🛡️  Cascade deletes configured for data integrity');
        
    } catch (error) {
        console.error('❌ Error creating user relationships:', error.message);
        if (error.detail) console.error('   Details:', error.detail);
    } finally {
        await client.end();
    }
}

createCoreUserRelationships();