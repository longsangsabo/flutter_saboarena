#!/usr/bin/env node

const { Client } = require('pg');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

async function checkUsersTable() {
    const client = new Client({
        connectionString: process.env.POOLER_URL,
        ssl: { rejectUnauthorized: false }
    });

    try {
        await client.connect();
        console.log('🔍 Checking users table structure...');
        
        // Check table structure
        const columns = await client.query(`
            SELECT column_name, data_type, is_nullable, column_default
            FROM information_schema.columns 
            WHERE table_name = 'users' 
            ORDER BY ordinal_position;
        `);
        
        console.log('\n📋 Users table columns:');
        columns.rows.forEach((col, i) => {
            console.log(`   ${i+1}. ${col.column_name} (${col.data_type}) nullable: ${col.is_nullable}`);
        });
        
        // Check PRIMARY KEY
        const pk = await client.query(`
            SELECT constraint_name, column_name 
            FROM information_schema.key_column_usage 
            WHERE table_name = 'users' 
            AND constraint_name IN (
                SELECT constraint_name 
                FROM information_schema.table_constraints 
                WHERE table_name = 'users' AND constraint_type = 'PRIMARY KEY'
            );
        `);
        
        console.log('\n🔑 Primary key info:');
        if (pk.rows.length > 0) {
            pk.rows.forEach(row => {
                console.log(`   ${row.constraint_name}: ${row.column_name}`);
            });
        } else {
            console.log('   ❌ No PRIMARY KEY found!');
        }
        
        // Check unique constraints
        const unique = await client.query(`
            SELECT constraint_name, column_name 
            FROM information_schema.key_column_usage 
            WHERE table_name = 'users' 
            AND constraint_name IN (
                SELECT constraint_name 
                FROM information_schema.table_constraints 
                WHERE table_name = 'users' AND constraint_type = 'UNIQUE'
            );
        `);
        
        console.log('\n🎯 Unique constraints:');
        if (unique.rows.length > 0) {
            unique.rows.forEach(row => {
                console.log(`   ${row.constraint_name}: ${row.column_name}`);
            });
        } else {
            console.log('   ❌ No UNIQUE constraints found!');
        }
        
        // Check all constraints
        const constraints = await client.query(`
            SELECT constraint_name, constraint_type
            FROM information_schema.table_constraints 
            WHERE table_name = 'users';
        `);
        
        console.log('\n📊 All constraints on users table:');
        constraints.rows.forEach(row => {
            console.log(`   ${row.constraint_type}: ${row.constraint_name}`);
        });
        
    } catch (error) {
        console.error('❌ Error:', error.message);
    } finally {
        await client.end();
    }
}

checkUsersTable();