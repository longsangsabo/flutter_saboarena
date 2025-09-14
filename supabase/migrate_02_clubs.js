#!/usr/bin/env node

const { Client } = require('pg');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

async function migrateClubsTable() {
    const client = new Client({
        connectionString: process.env.POOLER_URL,
        ssl: { rejectUnauthorized: false }
    });

    try {
        console.log('🏢 Migrating clubs table - Billiards Venues & Clubs...');
        await client.connect();
        console.log('✅ Connected to database');
        
        // Check current clubs table structure
        const tableExists = await client.query(`
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_schema = 'public' AND table_name = 'clubs'
            );
        `);
        
        if (tableExists.rows[0].exists) {
            console.log('⚠️  Clubs table already exists. Analyzing structure...');
            
            const columns = await client.query(`
                SELECT column_name, data_type, is_nullable, column_default
                FROM information_schema.columns 
                WHERE table_name = 'clubs' 
                ORDER BY ordinal_position;
            `);
            
            console.log('📋 Current clubs table structure:');
            columns.rows.forEach((col, index) => {
                console.log(`   ${index + 1}. ${col.column_name} (${col.data_type})`);
            });
            
            const rowCount = await client.query('SELECT COUNT(*) FROM clubs');
            console.log(`📊 Current records: ${rowCount.rows[0].count}`);
            
            // Check indexes
            const indexes = await client.query(`
                SELECT indexname, indexdef 
                FROM pg_indexes 
                WHERE tablename = 'clubs';
            `);
            
            console.log('\n📊 Current indexes:');
            indexes.rows.forEach((idx, index) => {
                console.log(`   ${index + 1}. ${idx.indexname}`);
            });
            
            // Check RLS status
            const rlsStatus = await client.query(`
                SELECT relrowsecurity 
                FROM pg_class 
                WHERE relname = 'clubs';
            `);
            
            console.log(`🔒 RLS Status: ${rlsStatus.rows[0]?.relrowsecurity ? 'Enabled' : 'Disabled'}`);
            
            // Sample data analysis
            if (rowCount.rows[0].count > 0) {
                const sampleData = await client.query(`
                    SELECT name, city, member_count, is_verified 
                    FROM clubs 
                    LIMIT 3;
                `);
                
                console.log('\n📋 Sample clubs data:');
                sampleData.rows.forEach((club, index) => {
                    console.log(`   ${index + 1}. ${club.name} (${club.city}) - Members: ${club.member_count}, Verified: ${club.is_verified}`);
                });
            }
            
        } else {
            console.log('📋 Creating clubs table - Billiards venue management...');
            
            // Create clubs table matching exact schema
            await client.query(`
                CREATE TABLE clubs (
                    -- Primary identifier
                    club_id VARCHAR(255) PRIMARY KEY,
                    created_time TIMESTAMPTZ DEFAULT NOW(),
                    
                    -- Basic Information
                    name VARCHAR(255) NOT NULL,
                    description TEXT,
                    logo_url TEXT,
                    cover_photo_url TEXT,
                    
                    -- Location & Contact
                    address TEXT,
                    city VARCHAR(100),
                    phone_number VARCHAR(20),
                    email VARCHAR(255),
                    website_url TEXT,
                    
                    -- Ownership & Management
                    created_by VARCHAR(255),
                    owner VARCHAR(255),
                    
                    -- Statistics
                    member_count INTEGER DEFAULT 0,
                    total_tournaments INTEGER DEFAULT 0,
                    
                    -- Verification & Rating
                    is_verified BOOLEAN DEFAULT FALSE,
                    rating DECIMAL(3,2) DEFAULT 0.00,
                    total_ratings INTEGER DEFAULT 0,
                    
                    -- Additional Features
                    tags TEXT[],
                    amenities JSONB DEFAULT '{}',
                    operating_hours JSONB DEFAULT '{}'
                );
            `);
            
            console.log('✅ Clubs table created successfully!');
            
            // Create performance indexes
            console.log('📊 Creating performance indexes...');
            await client.query('CREATE INDEX idx_clubs_name ON clubs(name);');
            await client.query('CREATE INDEX idx_clubs_city ON clubs(city);');
            await client.query('CREATE INDEX idx_clubs_owner ON clubs(owner);');
            await client.query('CREATE INDEX idx_clubs_created_by ON clubs(created_by);');
            await client.query('CREATE INDEX idx_clubs_verified ON clubs(is_verified);');
            await client.query('CREATE INDEX idx_clubs_rating ON clubs(rating);');
            
            console.log('✅ Indexes created successfully!');
            
            // Enable Row Level Security
            console.log('🔒 Enabling Row Level Security...');
            await client.query('ALTER TABLE clubs ENABLE ROW LEVEL SECURITY;');
            
            // Create RLS policies
            // Public can view all clubs
            await client.query(`
                CREATE POLICY policy_clubs_public_view ON clubs
                    FOR SELECT USING (true);
            `);
            
            // Club owners can manage their clubs
            await client.query(`
                CREATE POLICY policy_clubs_owner_manage ON clubs
                    FOR ALL USING (auth.uid()::text = owner);
            `);
            
            // Club creators can manage their clubs
            await client.query(`
                CREATE POLICY policy_clubs_creator_manage ON clubs
                    FOR ALL USING (auth.uid()::text = created_by);
            `);
            
            console.log('✅ RLS policies applied!');
            
            // Add constraints for data integrity
            console.log('⚖️  Adding data constraints...');
            await client.query(`
                ALTER TABLE clubs ADD CONSTRAINT check_member_count_positive 
                CHECK (member_count >= 0);
            `);
            
            await client.query(`
                ALTER TABLE clubs ADD CONSTRAINT check_tournament_count_positive 
                CHECK (total_tournaments >= 0);
            `);
            
            await client.query(`
                ALTER TABLE clubs ADD CONSTRAINT check_rating_range 
                CHECK (rating >= 0.00 AND rating <= 5.00);
            `);
            
            console.log('✅ Data constraints applied!');
        }
        
        // Relationship analysis with users table
        console.log('\n🔗 Analyzing club-user relationships...');
        const ownerRelations = await client.query(`
            SELECT COUNT(*) as clubs_with_owners
            FROM clubs 
            WHERE owner_uid IS NOT NULL;
        `);
        
        console.log(`   📊 Clubs with owners: ${ownerRelations.rows[0].clubs_with_owners}`);
        
        // Check for clubs by status
        const statusBreakdown = await client.query(`
            SELECT status, COUNT(*) as count
            FROM clubs 
            GROUP BY status;
        `);
        
        console.log('   📊 Status breakdown:');
        statusBreakdown.rows.forEach(row => {
            console.log(`      ${row.status}: ${row.count}`);
        });
        
        // Check verification status
        const verificationStats = await client.query(`
            SELECT verified, COUNT(*) as count
            FROM clubs 
            GROUP BY verified;
        `);
        
        console.log('   � Verification status:');
        verificationStats.rows.forEach(row => {
            console.log(`      ${row.verified ? 'Verified' : 'Unverified'}: ${row.count}`);
        });
        
        // Final verification
        const finalCheck = await client.query(`
            SELECT 
                COUNT(*) as column_count,
                (SELECT COUNT(*) FROM clubs) as record_count
            FROM information_schema.columns 
            WHERE table_name = 'clubs';
        `);
        
        console.log('\n🎯 Clubs Table Migration Summary:');
        console.log(`   📋 Columns: ${finalCheck.rows[0].column_count}`);
        console.log(`   📊 Records: ${finalCheck.rows[0].record_count}`);
        console.log('   🔒 RLS: Enabled with public view + owner management');
        console.log('   📊 Indexes: Name, city, owner, creator, verification, rating');
        console.log('   ⚖️  Constraints: Positive counts, rating range (0-5)');
        console.log('\n✅ Clubs table manages:');
        console.log('   - Billiards venue information');
        console.log('   - Location & contact details');
        console.log('   - Membership statistics');
        console.log('   - Tournament hosting capabilities');
        console.log('   - Verification & rating system');
        console.log('   - Operating hours & amenities');
        console.log('\n🔗 Relationships:');
        console.log('   - users.club_id → clubs.club_id (member association)');
        console.log('   - clubs.owner_uid → users.uid (ownership)');
        console.log('   - Future: club_members table for many-to-many relationships');
        
    } catch (error) {
        console.error('❌ Error migrating clubs table:', error.message);
        if (error.detail) console.error('   Details:', error.detail);
    } finally {
        await client.end();
    }
}

migrateClubsTable();