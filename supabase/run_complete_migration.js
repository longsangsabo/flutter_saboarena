#!/usr/bin/env node

const { Client } = require('pg');
const fs = require('fs');
require('dotenv').config();

async function runCompleteMigration() {
    const client = new Client({
        connectionString: process.env.POOLER_URL,
        ssl: { rejectUnauthorized: false }
    });

    try {
        console.log('🚀 Running complete schema migration...');
        await client.connect();
        
        const migrationSQL = fs.readFileSync('migrations/000_complete_schema.sql', 'utf8');
        await client.query(migrationSQL);
        
        console.log('✅ Complete migration executed successfully!');
        
        // Check all tables
        const tablesCheck = await client.query(`
            SELECT table_name, 
                   (SELECT COUNT(*) FROM information_schema.columns 
                    WHERE table_name = t.table_name) as column_count
            FROM information_schema.tables t
            WHERE table_schema = 'public' 
            AND table_type = 'BASE TABLE'
            ORDER BY table_name
        `);
        
        console.log('\n📊 Created tables:');
        tablesCheck.rows.forEach(row => {
            console.log(`   ${row.table_name}: ${row.column_count} columns`);
        });
        
    } catch (error) {
        console.error('❌ Error:', error.message);
        console.error('   Details:', error.detail);
    } finally {
        await client.end();
    }
}

runCompleteMigration();