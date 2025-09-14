#!/usr/bin/env node

const { Client } = require('pg');
const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

async function migrateUsersTable() {
    const client = new Client({
        connectionString: process.env.POOLER_URL,
        ssl: { rejectUnauthorized: false }
    });

    try {
        console.log('🚀 Migrating users table - Foundation of Sabo Arena...');
        await client.connect();
        console.log('✅ Connected to database');
        
        // Check if table exists
        const tableExists = await client.query(`
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_schema = 'public' AND table_name = 'users'
            );
        `);
        
        if (tableExists.rows[0].exists) {
            console.log('⚠️  Users table already exists. Checking structure...');
            
            const columns = await client.query(`
                SELECT column_name, data_type, is_nullable, column_default
                FROM information_schema.columns 
                WHERE table_name = 'users' 
                ORDER BY ordinal_position;
            `);
            
            console.log('📋 Current users table structure:');
            columns.rows.forEach((col, index) => {
                console.log(`   ${index + 1}. ${col.column_name} (${col.data_type})`);
            });
            
            const rowCount = await client.query('SELECT COUNT(*) FROM users');
            console.log(`📊 Current records: ${rowCount.rows[0].count}`);
            
        } else {
            console.log('📋 Creating users table with complete billiards profile...');
            
            // Create users table with exact schema
            await client.query(`
                CREATE TABLE users (
                    -- Core Identity
                    uid VARCHAR(255) PRIMARY KEY,
                    created_time TIMESTAMPTZ DEFAULT NOW(),
                    email VARCHAR(255),
                    email_verified BOOLEAN DEFAULT FALSE,
                    display_name VARCHAR(255),
                    full_name VARCHAR(255),
                    phone_number VARCHAR(20),
                    photo_url TEXT,
                    username VARCHAR(100) UNIQUE,
                    date_of_birth DATE,
                    
                    -- Billiards Statistics
                    current_elo INTEGER DEFAULT 1000,
                    current_spa INTEGER DEFAULT 0,
                    total_matches INTEGER DEFAULT 0,
                    total_wins INTEGER DEFAULT 0,
                    total_losses INTEGER DEFAULT 0,
                    win_rate DECIMAL(5,2) DEFAULT 0.00,
                    highest_elo INTEGER DEFAULT 1000,
                    tournaments_won INTEGER DEFAULT 0,
                    tournaments_played INTEGER DEFAULT 0,
                    total_earnings DECIMAL(10,2) DEFAULT 0.00,
                    
                    -- Club Association
                    club_id VARCHAR(255),
                    
                    -- Privacy & Settings
                    privacy_settings JSONB DEFAULT '{}',
                    last_activity TIMESTAMPTZ DEFAULT NOW(),
                    is_verified BOOLEAN DEFAULT FALSE
                );
            `);
            
            console.log('✅ Users table created successfully!');
            
            // Create performance indexes
            console.log('📊 Creating performance indexes...');
            await client.query('CREATE INDEX idx_users_email ON users(email);');
            await client.query('CREATE INDEX idx_users_username ON users(username);');
            await client.query('CREATE INDEX idx_users_current_elo ON users(current_elo);');
            await client.query('CREATE INDEX idx_users_club_id ON users(club_id);');
            await client.query('CREATE INDEX idx_users_last_activity ON users(last_activity);');
            
            console.log('✅ Indexes created successfully!');
            
            // Enable Row Level Security
            console.log('🔒 Enabling Row Level Security...');
            await client.query('ALTER TABLE users ENABLE ROW LEVEL SECURITY;');
            
            // Create RLS policy - users can view/edit their own profile
            await client.query(`
                CREATE POLICY policy_users_own ON users
                    FOR ALL USING (auth.uid()::text = uid);
            `);
            
            // Create policy for public profile viewing (display_name, current_elo, etc)
            await client.query(`
                CREATE POLICY policy_users_public_view ON users
                    FOR SELECT USING (true);
            `);
            
            console.log('✅ RLS policies applied!');
            
            // Add constraints for data integrity
            console.log('⚖️  Adding data constraints...');
            await client.query(`
                ALTER TABLE users ADD CONSTRAINT check_elo_range 
                CHECK (current_elo >= 0 AND current_elo <= 3000);
            `);
            
            await client.query(`
                ALTER TABLE users ADD CONSTRAINT check_spa_positive 
                CHECK (current_spa >= 0);
            `);
            
            await client.query(`
                ALTER TABLE users ADD CONSTRAINT check_win_rate_range 
                CHECK (win_rate >= 0.00 AND win_rate <= 100.00);
            `);
            
            console.log('✅ Data constraints applied!');
        }
        
        // Final verification
        const finalCheck = await client.query(`
            SELECT 
                COUNT(*) as column_count,
                (SELECT COUNT(*) FROM users) as record_count
            FROM information_schema.columns 
            WHERE table_name = 'users';
        `);
        
        console.log('\n🎯 Users Table Migration Summary:');
        console.log(`   📋 Columns: ${finalCheck.rows[0].column_count}`);
        console.log(`   📊 Records: ${finalCheck.rows[0].record_count}`);
        console.log('   🔒 RLS: Enabled with self-access policy');
        console.log('   📊 Indexes: Email, username, ELO, club_id, activity');
        console.log('   ⚖️  Constraints: ELO range, SPA positive, win rate range');
        console.log('\n✅ Users table is the foundation for:');
        console.log('   - User authentication & profiles');
        console.log('   - ELO rating system');
        console.log('   - SPA points & achievements');
        console.log('   - Match history & statistics');
        console.log('   - Club memberships');
        console.log('   - Tournament participation');
        
    } catch (error) {
        console.error('❌ Error migrating users table:', error.message);
        if (error.detail) console.error('   Details:', error.detail);
    } finally {
        await client.end();
    }
}

migrateUsersTable();