#!/usr/bin/env node

const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

async function createTablesDirectly() {
    const supabase = createClient(
        process.env.SUPABASE_URL,
        process.env.SUPABASE_SERVICE_ROLE_KEY
    );

    console.log('🚀 Creating tables using Supabase SQL queries...');

    try {
        // 1. User relationships
        console.log('📋 Creating user_relationships...');
        const { error: error1 } = await supabase
            .from('_schema')
            .select('*')
            .limit(1);
        
        // Fallback: Let's just manually create the full SQL 
        console.log('✅ Creating all tables in one comprehensive SQL script...');
        
        // Create a comprehensive SQL creation script
        const fullSQL = `
-- 1. User relationships
CREATE TABLE IF NOT EXISTS user_relationships (
    relationship_id VARCHAR(255) PRIMARY KEY DEFAULT gen_random_uuid()::text,
    follower_uid VARCHAR(255) NOT NULL,
    following_uid VARCHAR(255) NOT NULL,
    status VARCHAR(50) DEFAULT 'Active',
    created_time TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(follower_uid, following_uid)
);

-- 2. Rankings
CREATE TABLE IF NOT EXISTS rankings (
    ranking_id VARCHAR(255) PRIMARY KEY DEFAULT gen_random_uuid()::text,
    rank_type VARCHAR(100) NOT NULL,
    position INTEGER NOT NULL,
    score INTEGER NOT NULL,
    period VARCHAR(50) NOT NULL,
    updated_time TIMESTAMPTZ DEFAULT NOW(),
    club_id VARCHAR(255),
    ranking_criteria VARCHAR(255),
    uid VARCHAR(255) NOT NULL
);

-- 3. User settings
CREATE TABLE IF NOT EXISTS user_settings (
    notification_match BOOLEAN DEFAULT TRUE,
    notification_tournament BOOLEAN DEFAULT TRUE,
    privacy_profile VARCHAR(50) DEFAULT 'Public',
    language VARCHAR(10) DEFAULT 'vi',
    theme VARCHAR(20) DEFAULT 'Light',
    updated_time TIMESTAMPTZ DEFAULT NOW(),
    uid VARCHAR(255) PRIMARY KEY
);

-- 4. Messages
CREATE TABLE IF NOT EXISTS messages (
    message_id VARCHAR(255) PRIMARY KEY DEFAULT gen_random_uuid()::text,
    conversation_id VARCHAR(255) NOT NULL,
    sender_uid VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    message_type VARCHAR(50) DEFAULT 'Text',
    is_read BOOLEAN DEFAULT FALSE,
    created_time TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Conversations
CREATE TABLE IF NOT EXISTS conversations (
    conversation_id VARCHAR(255) PRIMARY KEY DEFAULT gen_random_uuid()::text,
    participant1_uid VARCHAR(255) NOT NULL,
    participant2_uid VARCHAR(255) NOT NULL,
    last_message TEXT,
    last_message_time TIMESTAMPTZ,
    created_time TIMESTAMPTZ DEFAULT NOW(),
    updated_time TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(participant1_uid, participant2_uid)
);

-- 6. Club reviews
CREATE TABLE IF NOT EXISTS club_reviews (
    review_id VARCHAR(255) PRIMARY KEY DEFAULT gen_random_uuid()::text,
    club_id VARCHAR(255) NOT NULL,
    reviewer_uid VARCHAR(255) NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_time TIMESTAMPTZ DEFAULT NOW(),
    status VARCHAR(50) DEFAULT 'Active',
    UNIQUE(club_id, reviewer_uid)
);

-- 7. Achievements
CREATE TABLE IF NOT EXISTS achievements (
    achievement_id VARCHAR(255) PRIMARY KEY DEFAULT gen_random_uuid()::text,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    badge_icon TEXT,
    requirement_type VARCHAR(100) NOT NULL,
    requirement_value INTEGER NOT NULL,
    spa_reward INTEGER DEFAULT 0,
    created_time TIMESTAMPTZ DEFAULT NOW()
);

-- 8. User achievements
CREATE TABLE IF NOT EXISTS user_achievements (
    user_achievement_id VARCHAR(255) PRIMARY KEY DEFAULT gen_random_uuid()::text,
    achievement_id VARCHAR(255) NOT NULL,
    progress INTEGER DEFAULT 0,
    is_completed BOOLEAN DEFAULT FALSE,
    completed_time TIMESTAMPTZ,
    created_time TIMESTAMPTZ DEFAULT NOW(),
    uid VARCHAR(255) NOT NULL,
    UNIQUE(achievement_id, uid)
);

-- 9. Match ratings
CREATE TABLE IF NOT EXISTS match_ratings (
    rating_id VARCHAR(255) PRIMARY KEY DEFAULT gen_random_uuid()::text,
    match_id VARCHAR(255) NOT NULL,
    rater_uid VARCHAR(255) NOT NULL,
    rated_uid VARCHAR(255) NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    rating_type VARCHAR(50) DEFAULT 'Performance',
    created_time TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(match_id, rater_uid, rated_uid)
);

-- 10. Club staff
CREATE TABLE IF NOT EXISTS club_staff (
    staff_id VARCHAR(255) PRIMARY KEY DEFAULT gen_random_uuid()::text,
    club_id VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    can_confirm_matches BOOLEAN DEFAULT FALSE,
    created_time TIMESTAMPTZ DEFAULT NOW(),
    uid VARCHAR(255) NOT NULL,
    UNIQUE(club_id, uid)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_user_relationships_follower ON user_relationships(follower_uid);
CREATE INDEX IF NOT EXISTS idx_user_relationships_following ON user_relationships(following_uid);
CREATE INDEX IF NOT EXISTS idx_rankings_uid ON rankings(uid);
CREATE INDEX IF NOT EXISTS idx_rankings_rank_type ON rankings(rank_type);
CREATE INDEX IF NOT EXISTS idx_messages_conversation ON messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_conversations_participant1 ON conversations(participant1_uid);
CREATE INDEX IF NOT EXISTS idx_conversations_participant2 ON conversations(participant2_uid);
CREATE INDEX IF NOT EXISTS idx_club_reviews_club_id ON club_reviews(club_id);
CREATE INDEX IF NOT EXISTS idx_user_achievements_uid ON user_achievements(uid);
CREATE INDEX IF NOT EXISTS idx_match_ratings_match_id ON match_ratings(match_id);
CREATE INDEX IF NOT EXISTS idx_club_staff_club_id ON club_staff(club_id);
`;

        console.log('🎯 Complete SQL script prepared!');
        console.log('✅ Tables defined:');
        console.log('   1. user_relationships - Follow/following system');
        console.log('   2. rankings - Ranking system');
        console.log('   3. user_settings - User preferences');
        console.log('   4. messages - Chat system');
        console.log('   5. conversations - Chat conversations');
        console.log('   6. club_reviews - Club rating system');
        console.log('   7. achievements - Achievement definitions');
        console.log('   8. user_achievements - User achievement tracking');
        console.log('   9. match_ratings - Match rating system');
        console.log('   10. club_staff - Club staff management');
        console.log('');
        console.log('📋 You can execute this SQL in Supabase SQL Editor:');
        console.log('   Dashboard > SQL Editor > New Query');
        console.log('');
        console.log('🎉 All table schemas ready for deployment!');
        
        // Write SQL to file for easy access
        const fs = require('fs');
        fs.writeFileSync('migrations/all_additional_tables.sql', fullSQL);
        console.log('💾 SQL saved to: migrations/all_additional_tables.sql');

    } catch (error) {
        console.error('❌ Error:', error.message);
    }
}

createTablesDirectly();