# Supabase Deployment Guide

## Prerequisites

1. **Install Supabase CLI**
   ```bash
   npm install -g supabase
   ```

2. **Login to Supabase**
   ```bash
   supabase login
   ```

## Project Setup

1. **Create a new Supabase project**
   - Go to [supabase.com](https://supabase.com)
   - Click "New Project"
   - Choose organization and region
   - Set database password

2. **Link your local project**
   ```bash
   supabase link --project-ref skzirkhzwhyqmnfyytcl
   ```

3. **Copy environment variables**
   ```bash
   cp supabase/.env.example supabase/.env
   ```
   
   Your actual values are already configured:
   - SUPABASE_URL: https://skzirkhzwhyqmnfyytcl.supabase.co
   - SUPABASE_ANON_KEY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   - SUPABASE_SERVICE_ROLE_KEY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

## Database Migration

1. **Apply database schema**
   ```bash
   supabase db push
   ```

2. **Insert sample data (optional)**
   ```bash
   supabase db reset --db-url "your-database-url"
   ```

## Edge Functions Deployment

1. **Deploy all functions**
   ```bash
   supabase functions deploy
   ```

2. **Deploy individual functions**
   ```bash
   supabase functions deploy create-match-from-challenge
   supabase functions deploy register-tournament
   supabase functions deploy update-match-result
   supabase functions deploy update-leaderboards
   supabase functions deploy send-notifications
   ```

## Authentication Setup

1. **Configure OAuth providers**
   - Go to Authentication > Settings in Supabase Dashboard
   - Enable Google OAuth:
     - Client ID: `your-google-client-id`
     - Client Secret: `your-google-client-secret`
   - Enable Apple OAuth (optional):
     - Client ID: `your-apple-client-id`
     - Client Secret: `your-apple-client-secret`

2. **Configure redirect URLs**
   - Add your app's redirect URLs
   - For development: `io.supabase.saboarena://login-callback`
   - For production: `your-production-scheme://login-callback`

## Storage Setup

1. **Create storage buckets**
   ```sql
   -- Create avatars bucket
   INSERT INTO storage.buckets (id, name, public)
   VALUES ('avatars', 'avatars', true);

   -- Create club-images bucket
   INSERT INTO storage.buckets (id, name, public)
   VALUES ('club-images', 'club-images', true);

   -- Create match-photos bucket
   INSERT INTO storage.buckets (id, name, public)
   VALUES ('match-photos', 'match-photos', true);
   ```

2. **Set storage policies**
   ```sql
   -- Avatar policies
   CREATE POLICY "Avatar images are publicly accessible." ON storage.objects
   FOR SELECT USING (bucket_id = 'avatars');

   CREATE POLICY "Users can upload their own avatar." ON storage.objects
   FOR INSERT WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);
   ```

## Real-time Configuration

1. **Enable real-time for tables**
   ```sql
   ALTER TABLE public.matches REPLICA IDENTITY FULL;
   ALTER TABLE public.chat_messages REPLICA IDENTITY FULL;
   ALTER TABLE public.notifications REPLICA IDENTITY FULL;
   ALTER TABLE public.leaderboards REPLICA IDENTITY FULL;
   ```

2. **Configure real-time policies**
   ```sql
   -- Enable real-time for matches
   ALTER PUBLICATION supabase_realtime ADD TABLE matches;
   ALTER PUBLICATION supabase_realtime ADD TABLE chat_messages;
   ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
   ALTER PUBLICATION supabase_realtime ADD TABLE leaderboards;
   ```

## Flutter App Configuration

1. **Update environment variables in Flutter**
   ```dart
   // lib/core/supabase_config.dart
   class SupabaseConfig {
     static const String supabaseUrl = 'https://skzirkhzwhyqmnfyytcl.supabase.co';
     static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNremlya2h6d2h5cW1uZnl5dGNsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc3NDM3MzUsImV4cCI6MjA3MzMxOTczNX0._0Ic0SL4FZVMennTXmOzIp2KBOCwRagpbRXaWhZJI24';
   }
   ```

2. **Configure deep linking for OAuth**
   - Update `android/app/src/main/AndroidManifest.xml`
   - Update `ios/Runner/Info.plist`

## Testing

1. **Run local Supabase (for development)**
   ```bash
   supabase start
   ```

2. **Test functions locally**
   ```bash
   supabase functions serve
   ```

3. **Test database queries**
   ```bash
   supabase db shell
   ```

## Production Deployment

1. **Deploy to production**
   ```bash
   supabase functions deploy --project-ref skzirkhzwhyqmnfyytcl
   supabase db push --project-ref skzirkhzwhyqmnfyytcl
   ```

2. **Configure production environment variables**
   - Update OAuth redirect URLs
   - Set production database URL
   - Configure custom domain (optional)

## Monitoring and Maintenance

1. **Set up monitoring**
   - Configure alerts in Supabase Dashboard
   - Monitor function logs
   - Track database performance

2. **Regular maintenance**
   - Update leaderboards (can be automated with cron jobs)
   - Clean up old notifications
   - Backup database regularly

## Troubleshooting

1. **Common issues**
   - Check function logs: `supabase functions logs function-name`
   - Verify environment variables
   - Check RLS policies
   - Validate OAuth configuration

2. **Performance optimization**
   - Add database indexes for frequent queries
   - Optimize RLS policies
   - Use database functions for complex operations
   - Configure CDN for static assets