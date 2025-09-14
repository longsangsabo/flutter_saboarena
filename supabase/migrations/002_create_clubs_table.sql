-- Migration: Create clubs table
-- Description: Billiards clubs/venues table for Sabo Arena
-- Author: AI Assistant  
-- Date: 2025-09-14
-- Depends: 001_create_users_table.sql

-- Create custom enums
CREATE TYPE club_status AS ENUM (
    'active',
    'inactive', 
    'suspended',
    'pending_approval'
);

CREATE TYPE club_type AS ENUM (
    'public',
    'private',
    'semi_private',
    'tournament_venue'
);

CREATE TYPE amenity_type AS ENUM (
    'parking',
    'restaurant',
    'bar',
    'wifi',
    'pro_shop',
    'coaching',
    'tournaments',
    'leagues',
    'air_conditioning',
    'smoking_area',
    'vip_rooms',
    'live_streaming'
);

-- Create clubs table
CREATE TABLE club (
    -- Primary key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Basic information
    name VARCHAR(200) NOT NULL,
    slug VARCHAR(200) UNIQUE NOT NULL, -- URL-friendly name
    description TEXT,
    tagline VARCHAR(300),
    
    -- Contact information
    email VARCHAR(255),
    phone_number VARCHAR(20),
    website_url TEXT,
    
    -- Location
    address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country_code VARCHAR(2) NOT NULL, -- ISO country code
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    timezone VARCHAR(50) DEFAULT 'Asia/Ho_Chi_Minh',
    
    -- Club details
    club_type club_type DEFAULT 'public',
    status club_status DEFAULT 'pending_approval',
    established_year INTEGER,
    license_number VARCHAR(100),
    
    -- Facilities
    total_tables INTEGER DEFAULT 0,
    pool_tables INTEGER DEFAULT 0,
    snooker_tables INTEGER DEFAULT 0,
    carom_tables INTEGER DEFAULT 0,
    vip_rooms INTEGER DEFAULT 0,
    
    -- Table specifications (JSON array of table details)
    table_details JSONB DEFAULT '[]'::jsonb,
    
    -- Amenities
    amenities amenity_type[] DEFAULT ARRAY[]::amenity_type[],
    
    -- Operating hours (JSON object with day-wise hours)
    operating_hours JSONB DEFAULT '{
        "monday": {"open": "09:00", "close": "23:00", "closed": false},
        "tuesday": {"open": "09:00", "close": "23:00", "closed": false},
        "wednesday": {"open": "09:00", "close": "23:00", "closed": false},
        "thursday": {"open": "09:00", "close": "23:00", "closed": false},
        "friday": {"open": "09:00", "close": "24:00", "closed": false},
        "saturday": {"open": "09:00", "close": "24:00", "closed": false},
        "sunday": {"open": "10:00", "close": "22:00", "closed": false}
    }'::jsonb,
    
    -- Pricing
    hourly_rate DECIMAL(8,2),
    daily_rate DECIMAL(8,2),
    membership_fee DECIMAL(8,2),
    currency_code VARCHAR(3) DEFAULT 'VND',
    
    -- Images and media
    logo_url TEXT,
    cover_image_url TEXT,
    gallery_images JSONB DEFAULT '[]'::jsonb,
    virtual_tour_url TEXT,
    
    -- Ratings and reviews
    average_rating DECIMAL(3,2) DEFAULT 0.00,
    total_reviews INTEGER DEFAULT 0,
    total_likes INTEGER DEFAULT 0,
    
    -- Statistics
    total_members INTEGER DEFAULT 0,
    total_tournaments INTEGER DEFAULT 0,
    total_matches INTEGER DEFAULT 0,
    
    -- Owner and management
    owner_id UUID NOT NULL REFERENCES "user"(id) ON DELETE RESTRICT,
    manager_ids UUID[] DEFAULT ARRAY[]::UUID[],
    
    -- Verification and approval
    is_verified BOOLEAN DEFAULT FALSE,
    verified_at TIMESTAMPTZ,
    verified_by UUID REFERENCES "user"(id),
    
    -- Social media
    social_media JSONB DEFAULT '{}'::jsonb,
    
    -- Business settings
    allows_tournaments BOOLEAN DEFAULT TRUE,
    allows_reservations BOOLEAN DEFAULT TRUE,
    requires_membership BOOLEAN DEFAULT FALSE,
    auto_approve_members BOOLEAN DEFAULT TRUE,
    
    -- SEO and discovery
    keywords TEXT[],
    featured BOOLEAN DEFAULT FALSE,
    priority_score INTEGER DEFAULT 0,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    
    -- Constraints
    CONSTRAINT check_club_name_length CHECK (char_length(name) >= 2),
    CONSTRAINT check_club_slug_format CHECK (slug ~* '^[a-z0-9-]+$'),
    CONSTRAINT check_email_format CHECK (email IS NULL OR email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT check_phone_format CHECK (phone_number IS NULL OR phone_number ~* '^\+?[1-9]\d{1,14}$'),
    CONSTRAINT check_coordinates CHECK (
        (latitude IS NULL AND longitude IS NULL) OR 
        (latitude IS NOT NULL AND longitude IS NOT NULL AND 
         latitude BETWEEN -90 AND 90 AND longitude BETWEEN -180 AND 180)
    ),
    CONSTRAINT check_established_year CHECK (established_year IS NULL OR (established_year >= 1800 AND established_year <= EXTRACT(YEAR FROM NOW()))),
    CONSTRAINT check_table_counts CHECK (
        total_tables >= 0 AND pool_tables >= 0 AND snooker_tables >= 0 AND 
        carom_tables >= 0 AND vip_rooms >= 0 AND
        total_tables >= (pool_tables + snooker_tables + carom_tables)
    ),
    CONSTRAINT check_rating_range CHECK (average_rating >= 0.00 AND average_rating <= 5.00),
    CONSTRAINT check_review_counts CHECK (total_reviews >= 0 AND total_likes >= 0),
    CONSTRAINT check_member_counts CHECK (total_members >= 0 AND total_tournaments >= 0 AND total_matches >= 0),
    CONSTRAINT check_rates CHECK (
        (hourly_rate IS NULL OR hourly_rate >= 0) AND
        (daily_rate IS NULL OR daily_rate >= 0) AND
        (membership_fee IS NULL OR membership_fee >= 0)
    )
);

-- Create indexes for performance
CREATE INDEX idx_club_owner_id ON club(owner_id);
CREATE INDEX idx_club_status ON club(status);
CREATE INDEX idx_club_type ON club(club_type);
CREATE INDEX idx_club_city ON club(city);
CREATE INDEX idx_club_country_code ON club(country_code);
CREATE INDEX idx_club_slug ON club(slug);
CREATE INDEX idx_club_name ON club(name);
CREATE INDEX idx_club_created_at ON club(created_at);
CREATE INDEX idx_club_average_rating ON club(average_rating);
CREATE INDEX idx_club_featured ON club(featured);

-- Geographic indexes
CREATE INDEX idx_club_coordinates ON club(latitude, longitude) WHERE latitude IS NOT NULL AND longitude IS NOT NULL;

-- Full-text search index
CREATE INDEX idx_club_search ON club USING gin(to_tsvector('english', name || ' ' || COALESCE(description, '') || ' ' || city));

-- Partial indexes for active clubs
CREATE INDEX idx_club_active_city ON club(city) WHERE status = 'active' AND deleted_at IS NULL;
CREATE INDEX idx_club_active_rating ON club(average_rating) WHERE status = 'active' AND deleted_at IS NULL;

-- Unique constraints
CREATE UNIQUE INDEX uniq_club_slug_active ON club(slug) WHERE deleted_at IS NULL;

-- Enable Row Level Security
ALTER TABLE club ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Everyone can view active clubs
CREATE POLICY policy_select_club_public ON club
    FOR SELECT 
    USING (status = 'active' AND deleted_at IS NULL);

-- Club owners can view their own clubs regardless of status
CREATE POLICY policy_select_club_owner ON club
    FOR SELECT 
    USING (owner_id = (SELECT id FROM "user" WHERE auth_id = auth.uid()));

-- Club managers can view clubs they manage
CREATE POLICY policy_select_club_manager ON club
    FOR SELECT 
    USING ((SELECT id FROM "user" WHERE auth_id = auth.uid()) = ANY(manager_ids));

-- Only authenticated users can create clubs
CREATE POLICY policy_insert_club_auth ON club
    FOR INSERT 
    WITH CHECK (
        auth.uid() IS NOT NULL AND
        owner_id = (SELECT id FROM "user" WHERE auth_id = auth.uid())
    );

-- Club owners can update their clubs
CREATE POLICY policy_update_club_owner ON club
    FOR UPDATE 
    USING (owner_id = (SELECT id FROM "user" WHERE auth_id = auth.uid()))
    WITH CHECK (owner_id = (SELECT id FROM "user" WHERE auth_id = auth.uid()));

-- Club managers can update specific fields
CREATE POLICY policy_update_club_manager ON club
    FOR UPDATE 
    USING ((SELECT id FROM "user" WHERE auth_id = auth.uid()) = ANY(manager_ids))
    WITH CHECK ((SELECT id FROM "user" WHERE auth_id = auth.uid()) = ANY(manager_ids));

-- Soft delete for owners only
CREATE POLICY policy_delete_club_owner ON club
    FOR UPDATE 
    USING (
        owner_id = (SELECT id FROM "user" WHERE auth_id = auth.uid()) AND 
        deleted_at IS NULL
    )
    WITH CHECK (owner_id = (SELECT id FROM "user" WHERE auth_id = auth.uid()));

-- Create trigger for updated_at
CREATE TRIGGER trigger_club_updated_at
    BEFORE UPDATE ON club
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to generate club slug
CREATE OR REPLACE FUNCTION generate_club_slug(club_name TEXT)
RETURNS TEXT AS $$
DECLARE
    base_slug TEXT;
    final_slug TEXT;
    counter INTEGER := 0;
BEGIN
    -- Create base slug: lowercase, replace spaces with hyphens, remove special chars
    base_slug := lower(regexp_replace(regexp_replace(club_name, '[^a-zA-Z0-9\s]', '', 'g'), '\s+', '-', 'g'));
    base_slug := trim(both '-' from base_slug);
    
    -- Ensure slug is not empty
    IF base_slug = '' THEN
        base_slug := 'club';
    END IF;
    
    final_slug := base_slug;
    
    -- Check for uniqueness and append counter if needed
    WHILE EXISTS (SELECT 1 FROM club WHERE slug = final_slug AND deleted_at IS NULL) LOOP
        counter := counter + 1;
        final_slug := base_slug || '-' || counter;
    END LOOP;
    
    RETURN final_slug;
END;
$$ LANGUAGE plpgsql;

-- Function to update club statistics
CREATE OR REPLACE FUNCTION update_club_stats(
    club_id UUID,
    stat_type TEXT, -- 'member', 'tournament', 'match'
    increment INTEGER DEFAULT 1
)
RETURNS VOID AS $$
BEGIN
    CASE stat_type
        WHEN 'member' THEN
            UPDATE club SET total_members = total_members + increment WHERE id = club_id;
        WHEN 'tournament' THEN
            UPDATE club SET total_tournaments = total_tournaments + increment WHERE id = club_id;
        WHEN 'match' THEN
            UPDATE club SET total_matches = total_matches + increment WHERE id = club_id;
    END CASE;
    
    UPDATE club SET updated_at = NOW() WHERE id = club_id;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate distance between two points (Haversine formula)
CREATE OR REPLACE FUNCTION calculate_distance_km(
    lat1 DECIMAL, lon1 DECIMAL,
    lat2 DECIMAL, lon2 DECIMAL
)
RETURNS DECIMAL AS $$
DECLARE
    R DECIMAL := 6371; -- Earth's radius in kilometers
    dLat DECIMAL;
    dLon DECIMAL;
    a DECIMAL;
    c DECIMAL;
BEGIN
    IF lat1 IS NULL OR lon1 IS NULL OR lat2 IS NULL OR lon2 IS NULL THEN
        RETURN NULL;
    END IF;
    
    dLat := radians(lat2 - lat1);
    dLon := radians(lon2 - lon1);
    
    a := sin(dLat/2) * sin(dLat/2) + cos(radians(lat1)) * cos(radians(lat2)) * sin(dLon/2) * sin(dLon/2);
    c := 2 * atan2(sqrt(a), sqrt(1-a));
    
    RETURN R * c;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function to find nearby clubs
CREATE OR REPLACE FUNCTION find_nearby_clubs(
    user_lat DECIMAL,
    user_lon DECIMAL,
    radius_km DECIMAL DEFAULT 50
)
RETURNS TABLE (
    club_id UUID,
    club_name VARCHAR,
    distance_km DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.name,
        calculate_distance_km(user_lat, user_lon, c.latitude, c.longitude) as distance
    FROM club c
    WHERE 
        c.status = 'active' 
        AND c.deleted_at IS NULL
        AND c.latitude IS NOT NULL 
        AND c.longitude IS NOT NULL
        AND calculate_distance_km(user_lat, user_lon, c.latitude, c.longitude) <= radius_km
    ORDER BY distance;
END;
$$ LANGUAGE plpgsql;

-- Add comments
COMMENT ON TABLE club IS 'Billiards clubs and venues where players can play and tournaments are held';
COMMENT ON COLUMN club.slug IS 'URL-friendly unique identifier for the club';
COMMENT ON COLUMN club.table_details IS 'JSON array containing detailed specifications of each table';
COMMENT ON COLUMN club.operating_hours IS 'JSON object with daily operating hours';
COMMENT ON COLUMN club.amenities IS 'Array of available amenities at the club';
COMMENT ON COLUMN club.manager_ids IS 'Array of user IDs who can manage this club';
COMMENT ON COLUMN club.social_media IS 'JSON object with social media links';

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Successfully created clubs table with:';
    RAISE NOTICE '   - Comprehensive club information and facilities';
    RAISE NOTICE '   - Geographic search capabilities';
    RAISE NOTICE '   - Full-text search index';
    RAISE NOTICE '   - Owner and manager access control';
    RAISE NOTICE '   - Business logic functions';
    RAISE NOTICE '   - Rating and review system ready';
END $$;