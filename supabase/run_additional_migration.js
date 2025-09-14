#!/usr/bin/env node

const { Client } = require('pg');
const fs = require('fs');
require('dotenv').config();

async function runAdditionalTablesMigration() {
    const client = new Client({
        connectionString: process.env.POOLER_URL,
        ssl: { rejectUnauthorized: false }
    });

    try {
        console.log('🚀 Creating 10 additional tables...');
        await client.connect();
        
        const migrationSQL = fs.readFileSync('migrations/010_create_additional_tables.sql', 'utf8');
        await client.query(migrationSQL);
        
        console.log('✅ All additional tables created successfully!');
        
        // Check all tables in database
        const tablesCheck = await client.query(`
            SELECT table_name, 
                   (SELECT COUNT(*) FROM information_schema.columns 
                    WHERE table_name = t.table_name) as column_count
            FROM information_schema.tables t
            WHERE table_schema = 'public' 
            AND table_type = 'BASE TABLE'
            ORDER BY table_name
        `);
        
        console.log('\n📊 Complete database schema:');
        tablesCheck.rows.forEach(row => {
            console.log(`   ✅ ${row.table_name}: ${row.column_count} columns`);
        });
        
        console.log(`\n🎉 Total: ${tablesCheck.rows.length} tables in Sabo Arena database!`);
        
    } catch (error) {
        console.error('❌ Error:', error.message);
        if (error.detail) console.error('   Details:', error.detail);
    } finally {
        await client.end();
    }
}

runAdditionalTablesMigration();