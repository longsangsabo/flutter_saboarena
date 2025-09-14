#!/usr/bin/env node

const { Client } = require('pg');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

async function testConnection() {
    console.log('🔍 Testing database connection...');
    console.log('📍 Database URL:', process.env.POOLER_URL ? 'Present' : 'Missing');
    
    const client = new Client({
        connectionString: process.env.POOLER_URL,
        ssl: { rejectUnauthorized: false }
    });

    try {
        await client.connect();
        console.log('✅ Database connection successful!');
        
        const result = await client.query('SELECT NOW() as current_time, version() as pg_version');
        console.log('⏰ Database time:', result.rows[0].current_time);
        console.log('📊 PostgreSQL version:', result.rows[0].pg_version.split(' ')[1]);
        
        // Check existing tables
        const tables = await client.query(`
            SELECT table_name FROM information_schema.tables 
            WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
            ORDER BY table_name;
        `);
        
        console.log('\n📋 Existing tables:');
        if (tables.rows.length === 0) {
            console.log('   (No tables found)');
        } else {
            tables.rows.forEach((row, index) => {
                console.log(`   ${index + 1}. ${row.table_name}`);
            });
        }
        
        return true;
        
    } catch (error) {
        console.error('❌ Connection failed:', error.message);
        console.error('🔧 Check your .env file for correct POOLER_URL');
        return false;
    } finally {
        await client.end();
    }
}

testConnection();