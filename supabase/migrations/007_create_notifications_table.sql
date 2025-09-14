-- Migration: Create notifications table
-- Description: Notification system for Sabo Arena  
-- Author: AI Assistant
-- Date: 2025-09-14

-- Create notifications table matching existing schema exactly
CREATE TABLE notifications (
    -- Primary identifier
    notification_id VARCHAR(255) PRIMARY KEY,
    
    -- Recipients and sender
    recipient_uid VARCHAR(255),
    sender_uid VARCHAR(255),
    
    -- Notification content
    type VARCHAR(100),
    title VARCHAR(255),
    message TEXT,
    action_text VARCHAR(100),
    
    -- Related entities
    match_id VARCHAR(255),
    tournament_id VARCHAR(255),
    request_id VARCHAR(255),
    
    -- Status tracking
    is_read BOOLEAN DEFAULT FALSE,
    is_clicked BOOLEAN DEFAULT FALSE,
    status VARCHAR(50) DEFAULT 'Active',
    
    -- Timing
    created_time TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ
);

-- Create indexes for performance
CREATE INDEX idx_notifications_notification_id ON notifications(notification_id);
CREATE INDEX idx_notifications_recipient_uid ON notifications(recipient_uid);
CREATE INDEX idx_notifications_sender_uid ON notifications(sender_uid);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_status ON notifications(status);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_time ON notifications(created_time);
CREATE INDEX idx_notifications_expires_at ON notifications(expires_at);
CREATE INDEX idx_notifications_match_id ON notifications(match_id);
CREATE INDEX idx_notifications_tournament_id ON notifications(tournament_id);
CREATE INDEX idx_notifications_request_id ON notifications(request_id);

-- Create partial indexes for active notifications
CREATE INDEX idx_notifications_unread ON notifications(created_time) 
WHERE is_read = FALSE AND status = 'Active';

CREATE INDEX idx_notifications_active ON notifications(recipient_uid, created_time) 
WHERE status = 'Active';

-- Create composite indexes for common queries
CREATE INDEX idx_notifications_recipient_status ON notifications(recipient_uid, status);
CREATE INDEX idx_notifications_recipient_type ON notifications(recipient_uid, type);
CREATE INDEX idx_notifications_recipient_read ON notifications(recipient_uid, is_read);

-- Enable Row Level Security
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Users can view their own notifications
CREATE POLICY policy_notifications_recipient ON notifications
    FOR SELECT 
    USING (auth.uid()::text = recipient_uid);

-- Users can update their own notifications (mark as read/clicked)
CREATE POLICY policy_notifications_update_own ON notifications
    FOR UPDATE 
    USING (auth.uid()::text = recipient_uid)
    WITH CHECK (auth.uid()::text = recipient_uid);

-- System can create notifications (will be handled by functions)
CREATE POLICY policy_notifications_system_create ON notifications
    FOR INSERT 
    WITH CHECK (true);

-- Function to create a notification
CREATE OR REPLACE FUNCTION create_notification(
    target_recipient_uid VARCHAR(255),
    target_sender_uid VARCHAR(255),
    notification_type VARCHAR(100),
    notification_title VARCHAR(255),
    notification_message TEXT,
    action_text VARCHAR(100) DEFAULT NULL,
    related_match_id VARCHAR(255) DEFAULT NULL,
    related_tournament_id VARCHAR(255) DEFAULT NULL,
    related_request_id VARCHAR(255) DEFAULT NULL,
    expires_hours INTEGER DEFAULT NULL
)
RETURNS VARCHAR(255) AS $$
DECLARE
    new_notification_id VARCHAR(255);
    expires_time TIMESTAMPTZ;
BEGIN
    -- Generate notification ID
    new_notification_id := 'notif_' || extract(epoch from now())::bigint || '_' || substring(md5(random()::text), 1, 8);
    
    -- Calculate expiration time
    IF expires_hours IS NOT NULL THEN
        expires_time := NOW() + (expires_hours || ' hours')::INTERVAL;
    END IF;
    
    -- Insert notification
    INSERT INTO notifications (
        notification_id, recipient_uid, sender_uid,
        type, title, message, action_text,
        match_id, tournament_id, request_id,
        expires_at, created_time
    ) VALUES (
        new_notification_id, target_recipient_uid, target_sender_uid,
        notification_type, notification_title, notification_message, action_text,
        related_match_id, related_tournament_id, related_request_id,
        expires_time, NOW()
    );
    
    RETURN new_notification_id;
END;
$$ LANGUAGE plpgsql;

-- Function to mark notifications as read
CREATE OR REPLACE FUNCTION mark_notifications_read(
    target_recipient_uid VARCHAR(255),
    notification_ids VARCHAR(255)[] DEFAULT NULL,
    mark_all BOOLEAN DEFAULT FALSE
)
RETURNS INTEGER AS $$
DECLARE
    updated_count INTEGER;
BEGIN
    IF mark_all THEN
        -- Mark all unread notifications as read
        UPDATE notifications 
        SET is_read = TRUE
        WHERE recipient_uid = target_recipient_uid AND is_read = FALSE;
    ELSE
        -- Mark specific notifications as read
        UPDATE notifications 
        SET is_read = TRUE
        WHERE recipient_uid = target_recipient_uid 
        AND notification_id = ANY(notification_ids)
        AND is_read = FALSE;
    END IF;
    
    GET DIAGNOSTICS updated_count = ROW_COUNT;
    RETURN updated_count;
END;
$$ LANGUAGE plpgsql;

-- Function to clean up expired notifications
CREATE OR REPLACE FUNCTION cleanup_expired_notifications()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    UPDATE notifications 
    SET status = 'Expired'
    WHERE status = 'Active' 
    AND expires_at IS NOT NULL 
    AND expires_at < NOW();
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Function to get notification stats for a user
CREATE OR REPLACE FUNCTION get_notification_stats(
    target_user_uid VARCHAR(255)
)
RETURNS TABLE (
    total_count BIGINT,
    unread_count BIGINT,
    match_count BIGINT,
    tournament_count BIGINT,
    request_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*) as total_count,
        COUNT(*) FILTER (WHERE is_read = FALSE) as unread_count,
        COUNT(*) FILTER (WHERE type LIKE '%match%') as match_count,
        COUNT(*) FILTER (WHERE type LIKE '%tournament%') as tournament_count,
        COUNT(*) FILTER (WHERE type LIKE '%request%') as request_count
    FROM notifications 
    WHERE recipient_uid = target_user_uid 
    AND status = 'Active'
    AND (expires_at IS NULL OR expires_at > NOW());
END;
$$ LANGUAGE plpgsql;

-- Function to search notifications
CREATE OR REPLACE FUNCTION search_notifications(
    target_recipient_uid VARCHAR(255),
    notification_type VARCHAR(100) DEFAULT NULL,
    only_unread BOOLEAN DEFAULT FALSE,
    limit_count INTEGER DEFAULT 50,
    offset_count INTEGER DEFAULT 0
)
RETURNS TABLE (
    notification_id VARCHAR(255),
    sender_uid VARCHAR(255),
    type VARCHAR(100),
    title VARCHAR(255),
    message TEXT,
    action_text VARCHAR(100),
    match_id VARCHAR(255),
    tournament_id VARCHAR(255),
    request_id VARCHAR(255),
    is_read BOOLEAN,
    is_clicked BOOLEAN,
    created_time TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        n.notification_id,
        n.sender_uid,
        n.type,
        n.title,
        n.message,
        n.action_text,
        n.match_id,
        n.tournament_id,
        n.request_id,
        n.is_read,
        n.is_clicked,
        n.created_time
    FROM notifications n
    WHERE 
        n.recipient_uid = target_recipient_uid
        AND n.status = 'Active'
        AND (n.expires_at IS NULL OR n.expires_at > NOW())
        AND (notification_type IS NULL OR n.type = notification_type)
        AND (only_unread = FALSE OR n.is_read = FALSE)
    ORDER BY n.created_time DESC
    LIMIT limit_count
    OFFSET offset_count;
END;
$$ LANGUAGE plpgsql;

-- Add constraints
ALTER TABLE notifications 
ADD CONSTRAINT check_status_values CHECK (
    status IN ('Active', 'Read', 'Expired', 'Deleted')
);

ALTER TABLE notifications 
ADD CONSTRAINT check_recipient_not_empty CHECK (recipient_uid != '');

ALTER TABLE notifications 
ADD CONSTRAINT check_type_not_empty CHECK (type != '');

ALTER TABLE notifications 
ADD CONSTRAINT check_expires_after_creation CHECK (
    expires_at IS NULL OR expires_at > created_time
);

-- Add comments for documentation
COMMENT ON TABLE notifications IS 'Notification system for matches, tournaments, and user interactions';
COMMENT ON COLUMN notifications.notification_id IS 'Unique identifier for the notification';
COMMENT ON COLUMN notifications.type IS 'Type of notification: match_invite, tournament_start, etc.';
COMMENT ON COLUMN notifications.action_text IS 'Text for action button (Accept, View, etc.)';
COMMENT ON COLUMN notifications.is_clicked IS 'Whether user clicked on the notification action';
COMMENT ON COLUMN notifications.expires_at IS 'When this notification expires and should be hidden';

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Successfully created notifications table:';
    RAISE NOTICE '   - 15 columns matching Supabase schema exactly';
    RAISE NOTICE '   - Comprehensive notification management system';
    RAISE NOTICE '   - RLS policies for user privacy';
    RAISE NOTICE '   - Helper functions for common operations';
    RAISE NOTICE '   - Auto-expiration and cleanup capabilities';
END $$;