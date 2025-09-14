# 🚀 Supabase Migration Plan for Sabo Arena

## 📋 Migration Overview

### Current Firebase Stack
- **Authentication**: Firebase Auth (Google, Apple, Email/Password)
- **Database**: Cloud Firestore (NoSQL)
- **Storage**: Firebase Storage
- **Functions**: Cloud Functions
- **Analytics**: Firebase Performance

### Target Supabase Stack
- **Authentication**: Supabase Auth (OAuth, Magic Links, Email/Password)
- **Database**: PostgreSQL with Row Level Security (RLS)
- **Storage**: Supabase Storage
- **Functions**: Edge Functions (Deno)
- **Real-time**: Built-in real-time subscriptions

## 🗄️ Database Schema Migration

### PostgreSQL Schema Design

```sql
-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. Users Table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    auth_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255),
    display_name VARCHAR(100),
    username VARCHAR(50) UNIQUE,
    photo_url TEXT,
    phone_number VARCHAR(20),
    location VARCHAR(255),
    birth_date DATE,
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
    
    -- Game Statistics
    elo_rating INTEGER DEFAULT 1000,
    overall_ranking INTEGER,
    total_matches INTEGER DEFAULT 0,
    wins INTEGER DEFAULT 0,
    losses INTEGER DEFAULT 0,
    draws INTEGER DEFAULT 0,
    win_rate DECIMAL(5,2) DEFAULT 0.00,
    average_match_duration INTEGER DEFAULT 0, -- in minutes
    favorite_game_type VARCHAR(50),
    skill_level VARCHAR(20) DEFAULT 'beginner' CHECK (skill_level IN ('beginner', 'intermediate', 'advanced', 'pro')),
    
    -- Activity & Status
    is_online BOOLEAN DEFAULT false,
    last_active TIMESTAMP WITH TIME ZONE DEFAULT now(),
    account_status VARCHAR(20) DEFAULT 'active',
    is_verified BOOLEAN DEFAULT false,
    is_banned BOOLEAN DEFAULT false,
    ban_reason TEXT,
    
    -- Preferences (JSONB for flexibility)
    preferred_language VARCHAR(10) DEFAULT 'en',
    notification_settings JSONB DEFAULT '{}',
    privacy_settings JSONB DEFAULT '{}',
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 2. Clubs Table
CREATE TABLE clubs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    logo_url TEXT,
    cover_image_url TEXT,
    location VARCHAR(255),
    address TEXT,
    phone_number VARCHAR(20),
    email VARCHAR(255),
    website VARCHAR(255),
    
    -- Club Info
    established_date DATE,
    club_type VARCHAR(50),
    membership_fee DECIMAL(10,2),
    max_members INTEGER,
    current_members INTEGER DEFAULT 0,
    
    -- Settings
    is_public BOOLEAN DEFAULT true,
    requires_approval BOOLEAN DEFAULT false,
    club_rules TEXT,
    operating_hours JSONB DEFAULT '{}',
    
    -- Owner
    owner_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 3. Club Members Table
CREATE TABLE club_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'member' CHECK (role IN ('owner', 'admin', 'moderator', 'member')),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'banned', 'pending')),
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    
    -- Constraints
    UNIQUE(club_id, user_id)
);

-- 4. Tournaments Table
CREATE TABLE tournaments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    banner_image_url TEXT,
    
    -- Tournament Info
    tournament_type VARCHAR(50) DEFAULT 'single_elimination',
    game_type VARCHAR(50) DEFAULT '8_ball',
    max_participants INTEGER DEFAULT 16,
    current_participants INTEGER DEFAULT 0,
    entry_fee DECIMAL(10,2) DEFAULT 0.00,
    prize_pool DECIMAL(10,2) DEFAULT 0.00,
    
    -- Schedule
    registration_start TIMESTAMP WITH TIME ZONE,
    registration_end TIMESTAMP WITH TIME ZONE,
    tournament_start TIMESTAMP WITH TIME ZONE,
    tournament_end TIMESTAMP WITH TIME ZONE,
    
    -- Status
    status VARCHAR(20) DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'registration_open', 'registration_closed', 'in_progress', 'completed', 'cancelled')),
    
    -- Organization
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    organizer_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    -- Settings
    tournament_rules TEXT,
    bracket_settings JSONB DEFAULT '{}',
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 5. Tournament Participants Table
CREATE TABLE tournament_participants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tournament_id UUID REFERENCES tournaments(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    registration_date TIMESTAMP WITH TIME ZONE DEFAULT now(),
    seed_number INTEGER,
    status VARCHAR(20) DEFAULT 'registered' CHECK (status IN ('registered', 'checked_in', 'playing', 'eliminated', 'winner')),
    
    -- Constraints
    UNIQUE(tournament_id, user_id)
);

-- 6. Matches Table
CREATE TABLE matches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Participants
    player1_id UUID REFERENCES users(id) ON DELETE CASCADE,
    player2_id UUID REFERENCES users(id) ON DELETE CASCADE,
    winner_id UUID REFERENCES users(id),
    
    -- Match Info
    match_type VARCHAR(50) DEFAULT 'casual',
    game_type VARCHAR(50) DEFAULT '8_ball',
    tournament_id UUID REFERENCES tournaments(id) ON DELETE SET NULL,
    club_id UUID REFERENCES clubs(id) ON DELETE SET NULL,
    round_number INTEGER,
    bracket_position VARCHAR(50),
    
    -- Scores
    player1_score INTEGER DEFAULT 0,
    player2_score INTEGER DEFAULT 0,
    best_of INTEGER DEFAULT 1,
    
    -- Timing
    scheduled_time TIMESTAMP WITH TIME ZONE,
    start_time TIMESTAMP WITH TIME ZONE,
    end_time TIMESTAMP WITH TIME ZONE,
    duration_minutes INTEGER,
    
    -- Status
    status VARCHAR(20) DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled', 'disputed')),
    
    -- Additional Info
    match_details JSONB DEFAULT '{}',
    notes TEXT,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 7. Player Statistics Table
CREATE TABLE player_statistics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    -- Period
    period_type VARCHAR(20) DEFAULT 'all_time' CHECK (period_type IN ('daily', 'weekly', 'monthly', 'yearly', 'all_time')),
    period_start DATE,
    period_end DATE,
    
    -- Game Statistics
    games_played INTEGER DEFAULT 0,
    games_won INTEGER DEFAULT 0,
    games_lost INTEGER DEFAULT 0,
    games_drawn INTEGER DEFAULT 0,
    win_percentage DECIMAL(5,2) DEFAULT 0.00,
    
    -- ELO Statistics
    elo_rating INTEGER DEFAULT 1000,
    elo_peak INTEGER DEFAULT 1000,
    elo_change INTEGER DEFAULT 0,
    
    -- Performance Metrics
    average_game_duration INTEGER DEFAULT 0,
    longest_win_streak INTEGER DEFAULT 0,
    current_win_streak INTEGER DEFAULT 0,
    longest_loss_streak INTEGER DEFAULT 0,
    current_loss_streak INTEGER DEFAULT 0,
    
    -- Tournament Stats
    tournaments_participated INTEGER DEFAULT 0,
    tournaments_won INTEGER DEFAULT 0,
    tournaments_top3 INTEGER DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    
    -- Constraints
    UNIQUE(user_id, period_type, period_start)
);

-- 8. Leaderboards Table
CREATE TABLE leaderboards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Leaderboard Info
    name VARCHAR(255) NOT NULL,
    description TEXT,
    leaderboard_type VARCHAR(50) DEFAULT 'elo' CHECK (leaderboard_type IN ('elo', 'wins', 'tournaments', 'win_rate')),
    period_type VARCHAR(20) DEFAULT 'all_time' CHECK (period_type IN ('daily', 'weekly', 'monthly', 'yearly', 'all_time')),
    
    -- Scope
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE, -- NULL for global leaderboards
    game_type VARCHAR(50),
    
    -- Settings
    max_entries INTEGER DEFAULT 100,
    update_frequency VARCHAR(20) DEFAULT 'real_time',
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 9. Leaderboard Entries Table
CREATE TABLE leaderboard_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    leaderboard_id UUID REFERENCES leaderboards(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    -- Ranking
    rank INTEGER NOT NULL,
    score DECIMAL(10,2) NOT NULL,
    previous_rank INTEGER,
    rank_change INTEGER DEFAULT 0,
    
    -- Period
    period_start DATE,
    period_end DATE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    
    -- Constraints
    UNIQUE(leaderboard_id, user_id, period_start)
);

-- 10. Notifications Table
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    -- Content
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    
    -- Status
    is_read BOOLEAN DEFAULT false,
    is_sent BOOLEAN DEFAULT false,
    
    -- Data
    data JSONB DEFAULT '{}',
    action_url TEXT,
    
    -- Timestamps
    scheduled_time TIMESTAMP WITH TIME ZONE DEFAULT now(),
    sent_time TIMESTAMP WITH TIME ZONE,
    read_time TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 11. Chat Messages Table (for club/tournament chat)
CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Message Info
    content TEXT NOT NULL,
    message_type VARCHAR(20) DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'file', 'system')),
    
    -- Participants
    sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    -- Context
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    tournament_id UUID REFERENCES tournaments(id) ON DELETE CASCADE,
    match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
    
    -- Status
    is_edited BOOLEAN DEFAULT false,
    is_deleted BOOLEAN DEFAULT false,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    
    -- Constraints
    CHECK (
        (club_id IS NOT NULL AND tournament_id IS NULL AND match_id IS NULL) OR
        (club_id IS NULL AND tournament_id IS NOT NULL AND match_id IS NULL) OR
        (club_id IS NULL AND tournament_id IS NULL AND match_id IS NOT NULL)
    )
);
```

## 🔐 Row Level Security (RLS) Policies

```sql
-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE clubs ENABLE ROW LEVEL SECURITY;
ALTER TABLE club_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE tournaments ENABLE ROW LEVEL SECURITY;
ALTER TABLE tournament_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_statistics ENABLE ROW LEVEL SECURITY;
ALTER TABLE leaderboards ENABLE ROW LEVEL SECURITY;
ALTER TABLE leaderboard_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view all profiles" ON users FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = auth_id);
CREATE POLICY "Users can insert own profile" ON users FOR INSERT WITH CHECK (auth.uid() = auth_id);

-- Clubs policies
CREATE POLICY "Anyone can view public clubs" ON clubs FOR SELECT USING (is_public = true);
CREATE POLICY "Club owners can manage their clubs" ON clubs FOR ALL USING (auth.uid() = (SELECT auth_id FROM users WHERE id = owner_id));

-- Club members policies
CREATE POLICY "Club members can view club membership" ON club_members FOR SELECT USING (
    club_id IN (SELECT club_id FROM club_members WHERE user_id = (SELECT id FROM users WHERE auth_id = auth.uid()))
);

-- Add more RLS policies as needed...
```

## 📦 Flutter Dependencies Update

### Remove Firebase packages:
```yaml
# Remove these from pubspec.yaml
cloud_firestore: 5.6.9
firebase_auth: 5.6.0
firebase_core: 3.14.0
firebase_performance: 0.10.1+7
firebase_storage: 12.4.7
```

### Add Supabase packages:
```yaml
# Add these to pubspec.yaml
supabase_flutter: ^2.5.6
supabase: ^2.2.2
postgrest: ^2.1.1
gotrue: ^2.8.4
realtime_client: ^2.0.4
storage_client: ^2.0.1
```

## 🚀 Migration Steps

1. **Setup Supabase Project**
   - Create new Supabase project
   - Run SQL schema migration
   - Configure authentication providers
   - Setup storage buckets

2. **Update Flutter App**
   - Replace Firebase dependencies with Supabase
   - Update authentication logic
   - Migrate database queries
   - Update storage operations

3. **Migrate Data**
   - Export Firebase data
   - Transform and import to PostgreSQL
   - Verify data integrity

4. **Test and Deploy**
   - Test all features
   - Update CI/CD pipeline
   - Deploy to production

## 📝 Next Actions

1. Create Supabase project and run schema
2. Update pubspec.yaml with Supabase dependencies
3. Create Supabase configuration files
4. Migrate authentication system
5. Update database operations
6. Test migration