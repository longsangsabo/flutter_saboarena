# Supabase Configuration for Sabo Arena

## Project Setup

### 1. Create Supabase Project
1. Go to [https://supabase.com](https://supabase.com)
2. Sign up/Login
3. Create new project
4. Choose region (closest to your users)
5. Set strong database password

### 2. Get Project Details
After project creation, you'll need:
- Project URL: `https://your-project-id.supabase.co`
- Anon/Public Key: `eyJ...`
- Service Role Key: `eyJ...` (for admin operations)

### 3. Environment Variables
Create `.env` file in project root:

```env
# Supabase Configuration
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here

# App Configuration
APP_NAME=Sabo Arena
APP_ENVIRONMENT=development
```

### 4. Flutter Configuration
Create `lib/core/supabase_config.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://your-project-id.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key-here';
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true, // Set to false in production
    );
  }
  
  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;
  static SupabaseQueryBuilder get from => client.from;
  static SupabaseStorageClient get storage => client.storage;
}
```

## Database Setup Script

Save this as `supabase/migrations/001_initial_schema.sql` and run in Supabase SQL Editor:

```sql
-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create custom types
CREATE TYPE user_skill_level AS ENUM ('beginner', 'intermediate', 'advanced', 'pro');
CREATE TYPE user_gender AS ENUM ('male', 'female', 'other');
CREATE TYPE account_status AS ENUM ('active', 'inactive', 'suspended', 'banned');
CREATE TYPE club_member_role AS ENUM ('owner', 'admin', 'moderator', 'member');
CREATE TYPE member_status AS ENUM ('active', 'inactive', 'banned', 'pending');
CREATE TYPE tournament_status AS ENUM ('upcoming', 'registration_open', 'registration_closed', 'in_progress', 'completed', 'cancelled');
CREATE TYPE match_status AS ENUM ('scheduled', 'in_progress', 'completed', 'cancelled', 'disputed');
CREATE TYPE message_type AS ENUM ('text', 'image', 'file', 'system');

-- Insert the complete schema from migration plan here
-- (Copy the full SQL schema from the migration plan)
```

## Authentication Setup

### 1. Enable Auth Providers
In Supabase Dashboard → Authentication → Providers:
- Email (enabled by default)
- Google OAuth
- Apple OAuth (for iOS)

### 2. Auth Configuration
```dart
// lib/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;
  
  // Sign up with email
  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: userData,
    );
  }
  
  // Sign in with email
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  // Sign in with Google
  static Future<bool> signInWithGoogle() async {
    return await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.saboarena://login-callback/',
    );
  }
  
  // Sign out
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }
  
  // Get current user
  static User? get currentUser => _client.auth.currentUser;
  
  // Listen to auth changes
  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
```

## Storage Setup

### 1. Create Storage Buckets
In Supabase Dashboard → Storage:
- `avatars` (public)
- `club-logos` (public)
- `tournament-banners` (public)
- `match-media` (private)

### 2. Storage Service
```dart
// lib/services/storage_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class StorageService {
  static final SupabaseClient _client = Supabase.instance.client;
  
  // Upload avatar
  static Future<String?> uploadAvatar(File file, String userId) async {
    try {
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _client.storage.from('avatars').upload(fileName, file);
      return _client.storage.from('avatars').getPublicUrl(fileName);
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }
  
  // Upload club logo
  static Future<String?> uploadClubLogo(File file, String clubId) async {
    try {
      final fileName = '$clubId-logo-${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _client.storage.from('club-logos').upload(fileName, file);
      return _client.storage.from('club-logos').getPublicUrl(fileName);
    } catch (e) {
      print('Error uploading club logo: $e');
      return null;
    }
  }
}
```

## Database Service Examples

```dart
// lib/services/database_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  static final SupabaseClient _client = Supabase.instance.client;
  
  // Get user profile
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }
  
  // Update user profile
  static Future<bool> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _client
          .from('users')
          .update(data)
          .eq('id', userId);
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }
  
  // Get clubs
  static Future<List<Map<String, dynamic>>> getClubs({int limit = 20, int offset = 0}) async {
    try {
      final response = await _client
          .from('clubs')
          .select()
          .eq('is_public', true)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      return response;
    } catch (e) {
      print('Error getting clubs: $e');
      return [];
    }
  }
  
  // Create tournament
  static Future<String?> createTournament(Map<String, dynamic> tournamentData) async {
    try {
      final response = await _client
          .from('tournaments')
          .insert(tournamentData)
          .select()
          .single();
      return response['id'];
    } catch (e) {
      print('Error creating tournament: $e');
      return null;
    }
  }
}
```

## Real-time Subscriptions

```dart
// lib/services/realtime_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeService {
  static final SupabaseClient _client = Supabase.instance.client;
  
  // Subscribe to user status changes
  static RealtimeChannel subscribeToUserStatus(String userId, Function(Map<String, dynamic>) onUpdate) {
    return _client
        .channel('user-status-$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'users',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: userId,
          ),
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .subscribe();
  }
  
  // Subscribe to match updates
  static RealtimeChannel subscribeToMatch(String matchId, Function(Map<String, dynamic>) onUpdate) {
    return _client
        .channel('match-$matchId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'matches',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: matchId,
          ),
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .subscribe();
  }
}
```

## Edge Functions (Alternative to Firebase Cloud Functions)

Create `supabase/functions/elo-calculator/index.ts`:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { matchId, winnerId, loserId } = await req.json()
    
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Calculate new ELO ratings
    // Implementation here...

    return new Response(
      JSON.stringify({ success: true }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      },
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400 
      },
    )
  }
})
```

## Migration Checklist

- [ ] Create Supabase project
- [ ] Run initial schema migration
- [ ] Configure authentication providers
- [ ] Set up storage buckets with policies
- [ ] Update pubspec.yaml dependencies
- [ ] Create Supabase configuration files
- [ ] Migrate authentication logic
- [ ] Update database operations
- [ ] Set up real-time subscriptions
- [ ] Create Edge Functions
- [ ] Test all features
- [ ] Deploy and monitor