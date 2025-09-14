#!/usr/bin/env node

const { Client } = require('pg');
const fs = require('fs');
require('dotenv').config();

async function runClubsMigration() {
    const client = new Client({
        connectionString: process.env.POOLER_URL,
        ssl: { rejectUnauthorized: false }
    });

    try {
        console.log('🚀 Connecting to Supabase...');
        await client.connect();
        
        const migrationSQL = fs.readFileSync('migrations/003_create_clubs_exact.sql', 'utf8');
        
        console.log('📄 Creating clubs table...');
        await client.query(migrationSQL);
        
        console.log('✅ Clubs table created successfully!');
        
        // Verify table structure
        const tableCheck = await client.query(`
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_name = 'clubs' 
            ORDER BY ordinal_position
        `);
        
        console.log(`📋 Clubs table has ${tableCheck.rows.length} columns:`);
        tableCheck.rows.forEach((row, i) => {
            console.log(`   ${i+1}. ${row.column_name} (${row.data_type})`);
        });
        
    } catch (error) {
        console.error('❌ Error:', error.message);
    } finally {
        await client.end();
    }
}

runClubsMigration();