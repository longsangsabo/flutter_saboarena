#!/usr/bin/env node

const { Client } = require('pg');
const fs = require('fs');
require('dotenv').config();

async function runTournamentsMigration() {
    const client = new Client({
        connectionString: process.env.POOLER_URL,
        ssl: { rejectUnauthorized: false }
    });

    try {
        console.log('🚀 Connecting to Supabase...');
        await client.connect();
        
        const migrationSQL = fs.readFileSync('migrations/005_create_tournaments_table.sql', 'utf8');
        
        console.log('🏆 Creating tournaments table...');
        await client.query(migrationSQL);
        
        console.log('✅ Tournaments table created successfully!');
        
        // Verify table structure
        const tableCheck = await client.query(`
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_name = 'tournaments' 
            ORDER BY ordinal_position
        `);
        
        console.log(`📋 Tournaments table has ${tableCheck.rows.length} columns:`);
        tableCheck.rows.forEach((row, i) => {
            console.log(`   ${i+1}. ${row.column_name} (${row.data_type})`);
        });

        // Check indexes
        const indexesCheck = await client.query(`
            SELECT indexname 
            FROM pg_indexes 
            WHERE tablename = 'tournaments'
            ORDER BY indexname
        `);
        
        console.log(`📊 Indexes created: ${indexesCheck.rows.length}`);
        indexesCheck.rows.forEach((row, i) => {
            console.log(`   ${i+1}. ${row.indexname}`);
        });

        // Check functions
        const functionsCheck = await client.query(`
            SELECT routine_name 
            FROM information_schema.routines 
            WHERE routine_name LIKE '%tournament%' 
            ORDER BY routine_name
        `);
        
        console.log(`⚙️ Tournament functions created: ${functionsCheck.rows.length}`);
        functionsCheck.rows.forEach((row, i) => {
            console.log(`   ${i+1}. ${row.routine_name}`);
        });
        
    } catch (error) {
        console.error('❌ Error:', error.message);
        console.error('💡 Full error:', error);
    } finally {
        await client.end();
    }
}

runTournamentsMigration();