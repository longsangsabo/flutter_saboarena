#!/usr/bin/env node

// Migration Runner for Supabase using direct database connection
// Executes users table migration via PostgreSQL connection

const { Client } = require('pg');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

async function runMigration() {
    const client = new Client({
        connectionString: process.env.POOLER_URL || process.env.DATABASE_URL,
        ssl: {
            rejectUnauthorized: false
        }
    });

    try {
        console.log('🚀 Connecting to Supabase PostgreSQL...');
        await client.connect();
        console.log('✅ Connected successfully!');

        // Read migration file
        const migrationPath = path.join(__dirname, 'migrations', '001_create_users_table.sql');
        const migrationSQL = fs.readFileSync(migrationPath, 'utf8');

        console.log('📄 Executing users table migration...');
        
        // Execute the migration
        const result = await client.query(migrationSQL);
        
        console.log('✅ Migration executed successfully!');
        console.log('📊 Result:', result);

        // Verify table was created
        const tableCheck = await client.query(`
            SELECT table_name, column_name, data_type 
            FROM information_schema.columns 
            WHERE table_name = 'users' 
            ORDER BY ordinal_position
        `);

        console.log('🔍 Verifying users table structure:');
        console.log(`📋 Found ${tableCheck.rows.length} columns in users table`);
        
        tableCheck.rows.forEach((row, index) => {
            console.log(`   ${index + 1}. ${row.column_name} (${row.data_type})`);
        });

    } catch (error) {
        console.error('❌ Migration failed:', error.message);
        console.error('🔍 Error details:', error);
        process.exit(1);
    } finally {
        await client.end();
        console.log('🔌 Database connection closed');
    }
}

// Install pg package if needed
console.log('📦 Checking for pg package...');
try {
    require('pg');
} catch (error) {
    console.log('📦 Installing pg package...');
    require('child_process').execSync('npm install pg', { stdio: 'inherit' });
}

// Run the migration
runMigration();