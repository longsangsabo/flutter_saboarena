#!/usr/bin/env node

const { Client } = require('pg');
const fs = require('fs');
require('dotenv').config();

async function runMatchRequestsMigration() {
    const client = new Client({
        connectionString: process.env.POOLER_URL,
        ssl: { rejectUnauthorized: false }
    });

    try {
        console.log('🚀 Creating notifications table...');
        await client.connect();
        
        const migrationSQL = fs.readFileSync('migrations/007_create_notifications_table.sql', 'utf8');
        await client.query(migrationSQL);
        
        console.log('✅ notifications table created successfully!');
        
        const tableCheck = await client.query(`
            SELECT COUNT(*) as column_count FROM information_schema.columns 
            WHERE table_name = 'notifications'
        `);
        console.log(`📋 Columns: ${tableCheck.rows[0].column_count}`);
        
    } catch (error) {
        console.error('❌ Error:', error.message);
    } finally {
        await client.end();
    }
}

runMatchRequestsMigration();