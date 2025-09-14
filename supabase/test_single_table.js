#!/usr/bin/env node

const { Client } = require('pg');
const fs = require('fs');
require('dotenv').config();

async function runSingleTableCreation() {
    const client = new Client({
        connectionString: process.env.POOLER_URL,
        ssl: { rejectUnauthorized: false }
    });

    try {
        await client.connect();
        console.log('🔌 Connected to database successfully');
        
        // Test connection with simple query
        const testResult = await client.query('SELECT NOW() as current_time');
        console.log('⏰ Database time:', testResult.rows[0].current_time);
        
        // Check existing tables
        const existingTables = await client.query(`
            SELECT table_name FROM information_schema.tables 
            WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
            ORDER BY table_name
        `);
        
        console.log('\n📋 Existing tables:');
        existingTables.rows.forEach(row => {
            console.log(`   - ${row.table_name}`);
        });
        
        console.log('\n🚀 Creating user_relationships table...');
        
        // Create just one table first to test
        await client.query(`
            CREATE TABLE IF NOT EXISTS user_relationships (
                relationship_id VARCHAR(255) PRIMARY KEY,
                follower_uid VARCHAR(255) NOT NULL,
                following_uid VARCHAR(255) NOT NULL,
                status VARCHAR(50) DEFAULT 'Active',
                created_time TIMESTAMPTZ DEFAULT NOW(),
                UNIQUE(follower_uid, following_uid)
            );
        `);
        
        console.log('✅ user_relationships table created successfully!');
        
        // Enable RLS
        await client.query('ALTER TABLE user_relationships ENABLE ROW LEVEL SECURITY;');
        
        // Create policy
        await client.query(`
            CREATE POLICY policy_user_relationships_own ON user_relationships
                FOR ALL USING (auth.uid()::text IN (follower_uid, following_uid));
        `);
        
        console.log('✅ RLS and policies applied!');
        
    } catch (error) {
        console.error('❌ Error:', error.message);
        console.error('   Code:', error.code);
        if (error.detail) console.error('   Details:', error.detail);
        if (error.hint) console.error('   Hint:', error.hint);
    } finally {
        await client.end();
    }
}

runSingleTableCreation();