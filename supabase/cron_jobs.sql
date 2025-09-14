-- Enable the pg_cron extension
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Schedule leaderboard updates every hour
-- This will call the update-leaderboards Edge Function
SELECT cron.schedule(
  'update-leaderboards-hourly',
  '0 * * * *', -- Every hour at minute 0
  $$
  SELECT net.http_post(
    url := 'https://skzirkhzwhyqmnfyytcl.supabase.co/functions/v1/update-leaderboards',
    headers := '{"Content-Type": "application/json", "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNremlya2h6d2h5cW1uZnl5dGNsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1Nzc0MzczNSwiZXhwIjoyMDczMzE5NzM1fQ.xIlkzXWPUq6Kwcs__XEduFZnCEi_y4up8Hd536VDmy0"}'::jsonb,
    body := '{}'::jsonb
  );
  $$
);

-- Schedule tournament status updates every 15 minutes
-- This checks for tournaments that should change status
SELECT cron.schedule(
  'update-tournament-status',
  '*/15 * * * *', -- Every 15 minutes
  $$
  UPDATE tournaments 
  SET status = 'In Progress',
      updated_at = NOW()
  WHERE status = 'Registration' 
    AND start_time <= NOW() 
    AND end_time > NOW();

  UPDATE tournaments 
  SET status = 'Completed',
      updated_at = NOW()
  WHERE status = 'In Progress' 
    AND end_time <= NOW();
  $$
);

-- Schedule cleanup of old notifications (weekly)
-- Remove notifications older than 30 days
SELECT cron.schedule(
  'cleanup-old-notifications',
  '0 2 * * 0', -- Every Sunday at 2 AM
  $$
  DELETE FROM notifications 
  WHERE created_at < NOW() - INTERVAL '30 days';
  $$
);

-- Schedule cleanup of expired challenges (daily)
-- Remove challenges older than 7 days that are still pending
SELECT cron.schedule(
  'cleanup-expired-challenges',
  '0 3 * * *', -- Every day at 3 AM
  $$
  UPDATE challenges 
  SET status = 'Expired',
      updated_at = NOW()
  WHERE status = 'Pending' 
    AND created_at < NOW() - INTERVAL '7 days';
  $$
);

-- Schedule automatic tournament bracket generation
-- This checks for tournaments that are ready to start
SELECT cron.schedule(
  'generate-tournament-brackets',
  '*/30 * * * *', -- Every 30 minutes
  $$
  -- Update tournaments that have reached their participant limit
  UPDATE tournaments 
  SET status = 'Ready to Start',
      updated_at = NOW()
  WHERE status = 'Registration' 
    AND current_participants >= max_participants;

  -- Auto-start tournaments that have enough participants and passed start time
  UPDATE tournaments 
  SET status = 'In Progress',
      updated_at = NOW()
  WHERE status = 'Ready to Start' 
    AND start_time <= NOW()
    AND current_participants >= min_participants;
  $$
);

-- Schedule user activity status updates (every 5 minutes)
-- Mark users as offline if they haven't been active for 15 minutes
SELECT cron.schedule(
  'update-user-activity-status',
  '*/5 * * * *', -- Every 5 minutes
  $$
  UPDATE users 
  SET is_online = false,
      updated_at = NOW()
  WHERE is_online = true 
    AND last_active < NOW() - INTERVAL '15 minutes';
  $$
);

-- View all scheduled cron jobs
-- SELECT * FROM cron.job;

-- To remove a cron job (if needed):
-- SELECT cron.unschedule('job-name');