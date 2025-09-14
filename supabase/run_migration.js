#!/usr/bin/env node

// Migration Runner for Supabase
// Run users table migration using service role key

const fs = require('fs');
const path = require('path');
require('dotenv').config();

async function runMigration() {
    try {
        // Read the migration file
        const migrationPath = path.join(__dirname, 'migrations', '001_create_users_table.sql');
        const migrationSQL = fs.readFileSync(migrationPath, 'utf8');
        
        console.log('🚀 Starting users table migration...');
        console.log('📍 Supabase URL:', process.env.SUPABASE_URL);
        
        // Use fetch to execute the SQL
        const response = await fetch(`${process.env.SUPABASE_URL}/rest/v1/rpc/exec_sql`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${process.env.SUPABASE_SERVICE_ROLE_KEY}`,
                'apikey': process.env.SUPABASE_SERVICE_ROLE_KEY
            },
            body: JSON.stringify({
                sql: migrationSQL
            })
        });

        if (response.ok) {
            const result = await response.json();
            console.log('✅ Migration executed successfully!');
            console.log('📊 Result:', result);
        } else {
            const error = await response.text();
            console.error('❌ Migration failed:', error);
            throw new Error(`HTTP ${response.status}: ${error}`);
        }

    } catch (error) {
        console.error('💥 Error running migration:', error.message);
        process.exit(1);
    }
}

// Run the migration
runMigration();