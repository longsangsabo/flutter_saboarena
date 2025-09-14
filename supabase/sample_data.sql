-- =====================================================
-- SAMPLE DATA FOR SABO ARENA SUPABASE DATABASE
-- This script creates test data for all tables
-- =====================================================

-- Insert sample users (using mock auth_id values)
INSERT INTO users (
    id, auth_id, email, full_name, display_name, username, photo_url, 
    phone_number, location, birth_date, gender, elo_rating, wins, losses,
    skill_level, preferred_language, created_at, updated_at
) VALUES 
-- User 1: John Doe (Advanced player)
(
    '550e8400-e29b-41d4-a716-446655440001',
    '550e8400-e29b-41d4-a716-446655440001',
    'john.doe@example.com',
    'John Doe',
    'JohnD',
    'john_doe',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=john',
    '+1234567890',
    'New York, NY',
    '1990-05-15',
    'male',
    1450,
    85,
    32,
    'advanced',
    'en',
    now() - interval '6 months',
    now()
),
-- User 2: Jane Smith (Pro player)
(
    '550e8400-e29b-41d4-a716-446655440002',
    '550e8400-e29b-41d4-a716-446655440002',
    'jane.smith@example.com',
    'Jane Smith',
    'JaneS',
    'jane_smith',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=jane',
    '+1234567891',
    'Los Angeles, CA',
    '1988-08-22',
    'female',
    1650,
    120,
    28,
    'pro',
    'en',
    now() - interval '8 months',
    now()
),
-- User 3: Mike Johnson (Intermediate player)
(
    '550e8400-e29b-41d4-a716-446655440003',
    '550e8400-e29b-41d4-a716-446655440003',
    'mike.johnson@example.com',
    'Mike Johnson',
    'MikeJ',
    'mike_johnson',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=mike',
    '+1234567892',
    'Chicago, IL',
    '1992-12-10',
    'male',
    1200,
    45,
    38,
    'intermediate',
    'en',
    now() - interval '4 months',
    now()
),
-- User 4: Sarah Wilson (Beginner player)
(
    '550e8400-e29b-41d4-a716-446655440004',
    '550e8400-e29b-41d4-a716-446655440004',
    'sarah.wilson@example.com',
    'Sarah Wilson',
    'SarahW',
    'sarah_wilson',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=sarah',
    '+1234567893',
    'Miami, FL',
    '1995-03-28',
    'female',
    1050,
    15,
    22,
    'beginner',
    'en',
    now() - interval '2 months',
    now()
),
-- User 5: Alex Chen (Advanced player)
(
    '550e8400-e29b-41d4-a716-446655440005',
    '550e8400-e29b-41d4-a716-446655440005',
    'alex.chen@example.com',
    'Alex Chen',
    'AlexC',
    'alex_chen',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=alex',
    '+1234567894',
    'San Francisco, CA',
    '1991-07-14',
    'male',
    1380,
    67,
    29,
    'advanced',
    'en',
    now() - interval '5 months',
    now()
);

-- Insert sample clubs
INSERT INTO clubs (
    id, name, description, logo_url, cover_image_url, location, address,
    phone_number, email, website, established_date, club_type, membership_fee,
    max_members, is_public, requires_approval, owner_id, created_at, updated_at
) VALUES 
-- Club 1: Elite Billiards Club
(
    '660e8400-e29b-41d4-a716-446655440001',
    'Elite Billiards Club',
    'Premium billiards club for serious players. We offer professional tables, coaching, and regular tournaments.',
    'https://api.dicebear.com/7.x/shapes/svg?seed=elite',
    'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=800',
    'New York, NY',
    '123 Broadway, New York, NY 10001',
    '+1234567890',
    'info@elitebilliards.com',
    'https://elitebilliards.com',
    '2020-01-15',
    'premium',
    99.99,
    50,
    true,
    true,
    '550e8400-e29b-41d4-a716-446655440001', -- John Doe
    now() - interval '3 years',
    now()
),
-- Club 2: West Coast Pool Hall
(
    '660e8400-e29b-41d4-a716-446655440002',
    'West Coast Pool Hall',
    'Casual and friendly pool hall welcoming players of all skill levels. Great atmosphere for both practice and competition.',
    'https://api.dicebear.com/7.x/shapes/svg?seed=westcoast',
    'https://images.unsplash.com/photo-1566737236500-c8ac43014a8e?w=800',
    'Los Angeles, CA',
    '456 Sunset Blvd, Los Angeles, CA 90028',
    '+1234567891',
    'contact@westcoastpool.com',
    'https://westcoastpool.com',
    '2019-06-20',
    'casual',
    49.99,
    100,
    true,
    false,
    '550e8400-e29b-41d4-a716-446655440002', -- Jane Smith
    now() - interval '2 years',
    now()
),
-- Club 3: Chicago Cue Sports
(
    '660e8400-e29b-41d4-a716-446655440003',
    'Chicago Cue Sports',
    'Traditional billiards club in the heart of Chicago. Home to many local championships and professional events.',
    'https://api.dicebear.com/7.x/shapes/svg?seed=chicago',
    'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
    'Chicago, IL',
    '789 Michigan Ave, Chicago, IL 60611',
    '+1234567892',
    'hello@chicagocue.com',
    'https://chicagocue.com',
    '2018-03-10',
    'professional',
    79.99,
    75,
    true,
    true,
    '550e8400-e29b-41d4-a716-446655440003', -- Mike Johnson
    now() - interval '4 years',
    now()
);

-- Insert club members
INSERT INTO club_members (
    id, club_id, user_id, role, status, joined_at, approved_by, approved_at
) VALUES 
-- Elite Billiards Club members
('770e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 'owner', 'active', now() - interval '3 years', NULL, NULL),
('770e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', 'admin', 'active', now() - interval '2 years', '550e8400-e29b-41d4-a716-446655440001', now() - interval '2 years'),
('770e8400-e29b-41d4-a716-446655440003', '660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440005', 'member', 'active', now() - interval '1 year', '550e8400-e29b-41d4-a716-446655440001', now() - interval '1 year'),

-- West Coast Pool Hall members
('770e8400-e29b-41d4-a716-446655440004', '660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440002', 'owner', 'active', now() - interval '2 years', NULL, NULL),
('770e8400-e29b-41d4-a716-446655440005', '660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440004', 'member', 'active', now() - interval '6 months', NULL, now() - interval '6 months'),
('770e8400-e29b-41d4-a716-446655440006', '660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440005', 'member', 'active', now() - interval '8 months', NULL, now() - interval '8 months'),

-- Chicago Cue Sports members
('770e8400-e29b-41d4-a716-446655440007', '660e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440003', 'owner', 'active', now() - interval '4 years', NULL, NULL),
('770e8400-e29b-41d4-a716-446655440008', '660e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440001', 'member', 'active', now() - interval '1 year', '550e8400-e29b-41d4-a716-446655440003', now() - interval '1 year');

-- Insert sample tournaments
INSERT INTO tournaments (
    id, name, description, banner_image_url, tournament_type, game_type,
    max_participants, entry_fee, prize_pool, registration_start, registration_end,
    tournament_start, tournament_end, status, club_id, organizer_id, created_at, updated_at
) VALUES 
-- Tournament 1: Elite Championship (Completed)
(
    '880e8400-e29b-41d4-a716-446655440001',
    'Elite Championship 2024',
    'Annual championship tournament featuring the best players from Elite Billiards Club.',
    'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=800',
    'single_elimination',
    '8_ball',
    16,
    50.00,
    800.00,
    now() - interval '2 months',
    now() - interval '1 month 15 days',
    now() - interval '1 month',
    now() - interval '3 weeks',
    'completed',
    '660e8400-e29b-41d4-a716-446655440001',
    '550e8400-e29b-41d4-a716-446655440001',
    now() - interval '2 months',
    now()
),
-- Tournament 2: West Coast Open (In Progress)
(
    '880e8400-e29b-41d4-a716-446655440002',
    'West Coast Open 2024',
    'Open tournament welcoming players from all skill levels. Great prizes and fun atmosphere!',
    'https://images.unsplash.com/photo-1566737236500-c8ac43014a8e?w=800',
    'double_elimination',
    '9_ball',
    32,
    25.00,
    400.00,
    now() - interval '2 weeks',
    now() - interval '3 days',
    now() - interval '2 days',
    now() + interval '3 days',
    'in_progress',
    '660e8400-e29b-41d4-a716-446655440002',
    '550e8400-e29b-41d4-a716-446655440002',
    now() - interval '3 weeks',
    now()
),
-- Tournament 3: Chicago Classics (Registration Open)
(
    '880e8400-e29b-41d4-a716-446655440003',
    'Chicago Classics 2024',
    'Traditional 8-ball tournament following professional rules. Registration now open!',
    'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
    'round_robin',
    '8_ball',
    24,
    75.00,
    1200.00,
    now() - interval '1 week',
    now() + interval '2 weeks',
    now() + interval '3 weeks',
    now() + interval '4 weeks',
    'registration_open',
    '660e8400-e29b-41d4-a716-446655440003',
    '550e8400-e29b-41d4-a716-446655440003',
    now() - interval '2 weeks',
    now()
);

-- Insert tournament participants
INSERT INTO tournament_participants (
    id, tournament_id, user_id, registration_date, seed_number, status
) VALUES 
-- Elite Championship participants
('990e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', now() - interval '2 months', 1, 'eliminated'),
('990e8400-e29b-41d4-a716-446655440002', '880e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', now() - interval '2 months', 2, 'winner'),
('990e8400-e29b-41d4-a716-446655440003', '880e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440005', now() - interval '2 months', 3, 'eliminated'),

-- West Coast Open participants
('990e8400-e29b-41d4-a716-446655440004', '880e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440002', now() - interval '2 weeks', 1, 'playing'),
('990e8400-e29b-41d4-a716-446655440005', '880e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440004', now() - interval '2 weeks', 2, 'playing'),
('990e8400-e29b-41d4-a716-446655440006', '880e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440005', now() - interval '2 weeks', 3, 'eliminated'),

-- Chicago Classics participants
('990e8400-e29b-41d4-a716-446655440007', '880e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440001', now() - interval '1 week', 1, 'registered'),
('990e8400-e29b-41d4-a716-446655440008', '880e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440003', now() - interval '1 week', 2, 'registered');

-- Insert sample matches
INSERT INTO matches (
    id, player1_id, player2_id, winner_id, match_type, game_type,
    tournament_id, club_id, player1_score, player2_score, start_time,
    end_time, duration_minutes, status, created_at, updated_at
) VALUES 
-- Match 1: Completed tournament match
(
    'aa0e8400-e29b-41d4-a716-446655440001',
    '550e8400-e29b-41d4-a716-446655440001', -- John
    '550e8400-e29b-41d4-a716-446655440002', -- Jane
    '550e8400-e29b-41d4-a716-446655440002', -- Jane wins
    'tournament',
    '8_ball',
    '880e8400-e29b-41d4-a716-446655440001',
    '660e8400-e29b-41d4-a716-446655440001',
    3,
    5,
    now() - interval '3 weeks 2 hours',
    now() - interval '3 weeks 45 minutes',
    75,
    'completed',
    now() - interval '3 weeks 2 hours',
    now()
),
-- Match 2: Completed casual match
(
    'aa0e8400-e29b-41d4-a716-446655440002',
    '550e8400-e29b-41d4-a716-446655440003', -- Mike
    '550e8400-e29b-41d4-a716-446655440004', -- Sarah
    '550e8400-e29b-41d4-a716-446655440003', -- Mike wins
    'casual',
    '9_ball',
    NULL,
    '660e8400-e29b-41d4-a716-446655440002',
    7,
    4,
    now() - interval '1 week 3 hours',
    now() - interval '1 week 2 hours',
    60,
    'completed',
    now() - interval '1 week 3 hours',
    now()
),
-- Match 3: In progress tournament match
(
    'aa0e8400-e29b-41d4-a716-446655440003',
    '550e8400-e29b-41d4-a716-446655440002', -- Jane
    '550e8400-e29b-41d4-a716-446655440004', -- Sarah
    NULL,
    'tournament',
    '9_ball',
    '880e8400-e29b-41d4-a716-446655440002',
    '660e8400-e29b-41d4-a716-446655440002',
    4,
    2,
    now() - interval '30 minutes',
    NULL,
    NULL,
    'in_progress',
    now() - interval '30 minutes',
    now()
),
-- Match 4: Scheduled match
(
    'aa0e8400-e29b-41d4-a716-446655440004',
    '550e8400-e29b-41d4-a716-446655440001', -- John
    '550e8400-e29b-41d4-a716-446655440005', -- Alex
    NULL,
    'tournament',
    '8_ball',
    '880e8400-e29b-41d4-a716-446655440003',
    '660e8400-e29b-41d4-a716-446655440003',
    0,
    0,
    now() + interval '2 days 19:00:00',
    NULL,
    NULL,
    'scheduled',
    now(),
    now()
);

-- Insert sample notifications
INSERT INTO notifications (
    id, user_id, title, message, notification_type, is_read, data, created_at
) VALUES 
('bb0e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 'Tournament Registration', 'Chicago Classics 2024 registration is now open!', 'tournament', false, '{"tournament_id": "880e8400-e29b-41d4-a716-446655440003"}', now() - interval '1 day'),
('bb0e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440002', 'Match Result', 'You won your match against John Doe!', 'match_result', true, '{"match_id": "aa0e8400-e29b-41d4-a716-446655440001"}', now() - interval '3 weeks'),
('bb0e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440004', 'Club Invitation', 'You have been invited to join Elite Billiards Club', 'club_invitation', false, '{"club_id": "660e8400-e29b-41d4-a716-446655440001"}', now() - interval '2 days'),
('bb0e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440005', 'Match Reminder', 'Your match is starting in 1 hour', 'match_reminder', false, '{"match_id": "aa0e8400-e29b-41d4-a716-446655440004"}', now() - interval '1 hour');

-- Insert sample chat messages
INSERT INTO chat_messages (
    id, content, message_type, sender_id, club_id, tournament_id, match_id, created_at, updated_at
) VALUES 
-- Club chat messages
('cc0e8400-e29b-41d4-a716-446655440001', 'Welcome to Elite Billiards Club! 🎱', 'text', '550e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440001', NULL, NULL, now() - interval '1 day', now() - interval '1 day'),
('cc0e8400-e29b-41d4-a716-446655440002', 'Great tournament last week everyone!', 'text', '550e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440001', NULL, NULL, now() - interval '18 hours', now() - interval '18 hours'),

-- Tournament chat messages
('cc0e8400-e29b-41d4-a716-446655440003', 'Good luck to all participants! 🏆', 'text', '550e8400-e29b-41d4-a716-446655440002', NULL, '880e8400-e29b-41d4-a716-446655440002', NULL, now() - interval '2 days', now() - interval '2 days'),
('cc0e8400-e29b-41d4-a716-446655440004', 'The brackets have been updated', 'text', '550e8400-e29b-41d4-a716-446655440002', NULL, '880e8400-e29b-41d4-a716-446655440002', NULL, now() - interval '1 day', now() - interval '1 day'),

-- Match chat messages
('cc0e8400-e29b-41d4-a716-446655440005', 'Great game! 👏', 'text', '550e8400-e29b-41d4-a716-446655440001', NULL, NULL, 'aa0e8400-e29b-41d4-a716-446655440001', now() - interval '3 weeks', now() - interval '3 weeks'),
('cc0e8400-e29b-41d4-a716-446655440006', 'Thanks for the match!', 'text', '550e8400-e29b-41d4-a716-446655440002', NULL, NULL, 'aa0e8400-e29b-41d4-a716-446655440001', now() - interval '3 weeks', now() - interval '3 weeks');

-- Create some basic leaderboards
INSERT INTO leaderboards (
    id, name, description, leaderboard_type, period_type, club_id, max_entries, created_at, updated_at
) VALUES 
-- Global ELO leaderboard
('dd0e8400-e29b-41d4-a716-446655440001', 'Global ELO Rankings', 'Top players worldwide ranked by ELO rating', 'elo', 'all_time', NULL, 100, now() - interval '1 year', now()),
-- Elite Club leaderboard
('dd0e8400-e29b-41d4-a716-446655440002', 'Elite Club Champions', 'Top players in Elite Billiards Club', 'elo', 'all_time', '660e8400-e29b-41d4-a716-446655440001', 50, now() - interval '1 year', now()),
-- Monthly wins leaderboard
('dd0e8400-e29b-41d4-a716-446655440003', 'Monthly Winners', 'Most wins this month', 'wins', 'monthly', NULL, 50, now() - interval '30 days', now());

-- Insert leaderboard entries
INSERT INTO leaderboard_entries (
    id, leaderboard_id, user_id, rank, score, period_start, period_end, created_at, updated_at
) VALUES 
-- Global ELO rankings
('ee0e8400-e29b-41d4-a716-446655440001', 'dd0e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', 1, 1650.00, '2024-01-01', '2024-12-31', now(), now()), -- Jane
('ee0e8400-e29b-41d4-a716-446655440002', 'dd0e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 2, 1450.00, '2024-01-01', '2024-12-31', now(), now()), -- John
('ee0e8400-e29b-41d4-a716-446655440003', 'dd0e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440005', 3, 1380.00, '2024-01-01', '2024-12-31', now(), now()), -- Alex
('ee0e8400-e29b-41d4-a716-446655440004', 'dd0e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440003', 4, 1200.00, '2024-01-01', '2024-12-31', now(), now()), -- Mike
('ee0e8400-e29b-41d4-a716-446655440005', 'dd0e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440004', 5, 1050.00, '2024-01-01', '2024-12-31', now(), now()), -- Sarah

-- Elite Club rankings
('ee0e8400-e29b-41d4-a716-446655440006', 'dd0e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440002', 1, 1650.00, '2024-01-01', '2024-12-31', now(), now()), -- Jane
('ee0e8400-e29b-41d4-a716-446655440007', 'dd0e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 2, 1450.00, '2024-01-01', '2024-12-31', now(), now()), -- John
('ee0e8400-e29b-41d4-a716-446655440008', 'dd0e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440005', 3, 1380.00, '2024-01-01', '2024-12-31', now(), now()); -- Alex

-- Insert some player statistics
INSERT INTO player_statistics (
    id, user_id, period_type, period_start, period_end, games_played, games_won, games_lost, 
    win_percentage, elo_rating, elo_peak, tournaments_participated, tournaments_won, created_at, updated_at
) VALUES 
-- All-time stats for each user
('ff0e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 'all_time', '2024-01-01', '2024-12-31', 117, 85, 32, 72.65, 1450, 1520, 8, 2, now(), now()),
('ff0e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440002', 'all_time', '2024-01-01', '2024-12-31', 148, 120, 28, 81.08, 1650, 1720, 12, 5, now(), now()),
('ff0e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440003', 'all_time', '2024-01-01', '2024-12-31', 83, 45, 38, 54.22, 1200, 1280, 4, 0, now(), now()),
('ff0e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440004', 'all_time', '2024-01-01', '2024-12-31', 37, 15, 22, 40.54, 1050, 1100, 2, 0, now(), now()),
('ff0e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440005', 'all_time', '2024-01-01', '2024-12-31', 96, 67, 29, 69.79, 1380, 1420, 6, 1, now(), now());

-- Update club member counts (these will be automatically updated by triggers)
UPDATE clubs SET current_members = (
    SELECT COUNT(*) FROM club_members 
    WHERE club_id = clubs.id AND status = 'active'
);

-- Update tournament participant counts
UPDATE tournaments SET current_participants = (
    SELECT COUNT(*) FROM tournament_participants 
    WHERE tournament_id = tournaments.id
);

-- Update user win rates
UPDATE users SET 
    win_rate = CASE 
        WHEN total_matches > 0 THEN (wins * 100.0 / total_matches)
        ELSE 0 
    END,
    total_matches = wins + losses + draws;

-- Display summary of inserted data
SELECT 
    'Data Summary' as info,
    (SELECT COUNT(*) FROM users) as users_count,
    (SELECT COUNT(*) FROM clubs) as clubs_count,
    (SELECT COUNT(*) FROM club_members) as club_members_count,
    (SELECT COUNT(*) FROM tournaments) as tournaments_count,
    (SELECT COUNT(*) FROM tournament_participants) as tournament_participants_count,
    (SELECT COUNT(*) FROM matches) as matches_count,
    (SELECT COUNT(*) FROM notifications) as notifications_count,
    (SELECT COUNT(*) FROM chat_messages) as chat_messages_count,
    (SELECT COUNT(*) FROM leaderboards) as leaderboards_count,
    (SELECT COUNT(*) FROM leaderboard_entries) as leaderboard_entries_count,
    (SELECT COUNT(*) FROM player_statistics) as player_statistics_count;