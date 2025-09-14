#!/usr/bin/env node

const { Client } = require('pg');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

async function migrateUserSettingsTable() {
    const client = new Client({
        connectionString: process.env.POOLER_URL,
        ssl: { rejectUnauthorized: false }
    });

    try {
        console.log('⚙️  Migrating user_settings table - User Preferences & Configuration...');
        await client.connect();
        console.log('✅ Connected to database');
        
        // Check if table exists
        const tableExists = await client.query(`
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_schema = 'public' AND table_name = 'user_settings'
            );
        `);
        
        if (tableExists.rows[0].exists) {
            console.log('⚠️  user_settings table already exists. Analyzing structure...');
            
            const columns = await client.query(`
                SELECT column_name, data_type, is_nullable, column_default
                FROM information_schema.columns 
                WHERE table_name = 'user_settings' 
                ORDER BY ordinal_position;
            `);
            
            console.log('📋 Current user_settings table structure:');
            columns.rows.forEach((col, index) => {
                console.log(`   ${index + 1}. ${col.column_name} (${col.data_type}) ${col.is_nullable === 'NO' ? '* Required' : ''}`);
            });
            
            const rowCount = await client.query('SELECT COUNT(*) FROM user_settings');
            console.log(`📊 Current records: ${rowCount.rows[0].count}`);
            
        } else {
            console.log('📋 Creating user_settings table - User preferences management...');
            
            // Create user_settings table
            await client.query(`
                CREATE TABLE user_settings (
                    -- Primary key linking to users table
                    uid VARCHAR(255) PRIMARY KEY,
                    
                    -- Notification preferences
                    notification_match BOOLEAN DEFAULT TRUE,
                    notification_tournament BOOLEAN DEFAULT TRUE,
                    notification_friend_request BOOLEAN DEFAULT TRUE,
                    notification_achievement BOOLEAN DEFAULT TRUE,
                    notification_message BOOLEAN DEFAULT TRUE,
                    
                    -- Privacy settings
                    privacy_profile VARCHAR(50) DEFAULT 'Public',
                    privacy_stats VARCHAR(50) DEFAULT 'Public',
                    privacy_online_status VARCHAR(50) DEFAULT 'Friends',
                    
                    -- Appearance preferences
                    language VARCHAR(10) DEFAULT 'vi',
                    theme VARCHAR(20) DEFAULT 'Light',
                    
                    -- Game preferences
                    preferred_game_mode VARCHAR(50) DEFAULT '8-Ball',
                    auto_accept_challenges BOOLEAN DEFAULT FALSE,
                    challenge_elo_range INTEGER DEFAULT 200,
                    
                    -- System settings
                    sound_enabled BOOLEAN DEFAULT TRUE,
                    vibration_enabled BOOLEAN DEFAULT TRUE,
                    
                    -- Timestamps
                    created_time TIMESTAMPTZ DEFAULT NOW(),
                    updated_time TIMESTAMPTZ DEFAULT NOW()
                );
            `);
            
            console.log('✅ user_settings table created successfully!');
            
            // Create performance indexes
            console.log('📊 Creating performance indexes...');
            await client.query('CREATE INDEX idx_user_settings_uid ON user_settings(uid);');
            await client.query('CREATE INDEX idx_user_settings_privacy_profile ON user_settings(privacy_profile);');
            await client.query('CREATE INDEX idx_user_settings_language ON user_settings(language);');
            
            console.log('✅ Indexes created successfully!');
            
            // Enable Row Level Security
            console.log('🔒 Enabling Row Level Security...');
            await client.query('ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;');
            
            // Create RLS policies - users can only access their own settings
            await client.query(`
                CREATE POLICY policy_user_settings_own ON user_settings
                    FOR ALL USING (auth.uid()::text = uid);
            `);
            
            console.log('✅ RLS policies applied!');
            
            // Add constraints for data integrity
            console.log('⚖️  Adding data constraints...');
            await client.query(`
                ALTER TABLE user_settings ADD CONSTRAINT check_privacy_profile 
                CHECK (privacy_profile IN ('Public', 'Friends', 'Private'));
            `);
            
            await client.query(`
                ALTER TABLE user_settings ADD CONSTRAINT check_privacy_stats 
                CHECK (privacy_stats IN ('Public', 'Friends', 'Private'));
            `);
            
            await client.query(`
                ALTER TABLE user_settings ADD CONSTRAINT check_privacy_online_status 
                CHECK (privacy_online_status IN ('Public', 'Friends', 'Private'));
            `);
            
            await client.query(`
                ALTER TABLE user_settings ADD CONSTRAINT check_theme 
                CHECK (theme IN ('Light', 'Dark', 'Auto'));
            `);
            
            await client.query(`
                ALTER TABLE user_settings ADD CONSTRAINT check_language 
                CHECK (language IN ('vi', 'en', 'zh', 'ja', 'ko'));
            `);
            
            await client.query(`
                ALTER TABLE user_settings ADD CONSTRAINT check_elo_range_positive 
                CHECK (challenge_elo_range > 0 AND challenge_elo_range <= 1000);
            `);
            
            console.log('✅ Data constraints applied!');
            
            // Add foreign key relationship to users table
            console.log('🔗 Creating foreign key relationship...');
            try {
                await client.query(`
                    ALTER TABLE user_settings 
                    ADD CONSTRAINT fk_user_settings_uid 
                    FOREIGN KEY (uid) REFERENCES users(uid) ON DELETE CASCADE;
                `);
                console.log('✅ Foreign key constraint added!');
            } catch (fkError) {
                console.log('⚠️  Foreign key not added (users table may not have uid as primary key)');
            }
        }
        
        // Test relationship with users table
        console.log('\n🔗 Testing relationship with users table...');
        const userCount = await client.query('SELECT COUNT(*) FROM users');
        const settingsCount = await client.query('SELECT COUNT(*) FROM user_settings');
        
        console.log(`   📊 Total users: ${userCount.rows[0].count}`);
        console.log(`   📊 Users with settings: ${settingsCount.rows[0].count}`);
        
        if (userCount.rows[0].count > 0 && settingsCount.rows[0].count === 0) {
            console.log('💡 Consider creating default settings for existing users');
        }
        
        // Final verification
        const finalCheck = await client.query(`
            SELECT 
                COUNT(*) as column_count,
                (SELECT COUNT(*) FROM user_settings) as record_count
            FROM information_schema.columns 
            WHERE table_name = 'user_settings';
        `);
        
        console.log('\n🎯 User Settings Table Migration Summary:');
        console.log(`   📋 Columns: ${finalCheck.rows[0].column_count}`);
        console.log(`   📊 Records: ${finalCheck.rows[0].record_count}`);
        console.log('   🔒 RLS: Enabled with self-access only');
        console.log('   📊 Indexes: UID, privacy profile, language');
        console.log('   ⚖️  Constraints: Privacy levels, theme options, language codes');
        console.log('\n✅ User settings manages:');
        console.log('   - Notification preferences (matches, tournaments, friends)');
        console.log('   - Privacy controls (profile, stats, online status)');
        console.log('   - Appearance settings (language, theme)');
        console.log('   - Game preferences (mode, auto-accept, ELO range)');
        console.log('   - System settings (sound, vibration)');
        console.log('\n🔗 Relationships:');
        console.log('   - user_settings.uid → users.uid (one-to-one)');
        console.log('   - Cascade delete when user is removed');
        
    } catch (error) {
        console.error('❌ Error migrating user_settings table:', error.message);
        if (error.detail) console.error('   Details:', error.detail);
    } finally {
        await client.end();
    }
}

migrateUserSettingsTable();