#!/usr/bin/env node

const { Client } = require('pg');
const fs = require('fs');
require('dotenv').config();

async function runMatchesMigration() {
    const client = new Client({
        connectionString: process.env.POOLER_URL,
        ssl: { rejectUnauthorized: false }
    });

    try {
        console.log('🚀 Connecting to Supabase...');
        await client.connect();
        
        const migrationSQL = fs.readFileSync('migrations/004_create_matches_table.sql', 'utf8');
        
        console.log('📄 Creating matches table...');
        await client.query(migrationSQL);
        
        console.log('✅ Matches table created successfully!');
        
        // Verify table structure
        const tableCheck = await client.query(`
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_name = 'matches' 
            ORDER BY ordinal_position
        `);
        
        console.log(`📋 Matches table has ${tableCheck.rows.length} columns:`);
        tableCheck.rows.forEach((row, i) => {
            console.log(`   ${i+1}. ${row.column_name} (${row.data_type})`);
        });

        // Check foreign key constraints
        const constraintsCheck = await client.query(`
            SELECT constraint_name, constraint_type 
            FROM information_schema.table_constraints 
            WHERE table_name = 'matches' AND constraint_type = 'FOREIGN KEY'
        `);
        
        console.log(`🔗 Foreign key constraints: ${constraintsCheck.rows.length}`);
        constraintsCheck.rows.forEach((row, i) => {
            console.log(`   ${i+1}. ${row.constraint_name}`);
        });
        
    } catch (error) {
        console.error('❌ Error:', error.message);
    } finally {
        await client.end();
    }
}

runMatchesMigration();