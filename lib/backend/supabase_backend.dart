// Supabase Backend Integration for Sabo Arena
// This file replaces the Firebase backend with Supabase

import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';
import '../services/supabase_auth_service.dart';
import '../services/supabase_database_service.dart';
import '../services/supabase_storage_service.dart';
import '../services/supabase_realtime_service.dart';

// Import Firebase compatibility layer for gradual migration
import 'firebase_compatibility.dart';

// Export Supabase services for app-wide use
export '../core/supabase_config.dart';
export '../services/supabase_auth_service.dart';
export '../services/supabase_database_service.dart';
export '../services/supabase_storage_service.dart';
export '../services/supabase_realtime_service.dart';

// Export compatibility layer for existing components
export 'firebase_compatibility.dart';

// Global Supabase client getter
SupabaseClient get supabase => Supabase.instance.client;

// Service instances
final supabaseAuth = SupabaseAuthService();
final supabaseDatabase = SupabaseDatabaseService();
final supabaseStorage = SupabaseStorageService();
final supabaseRealtime = SupabaseRealtimeService();

// Initialize Supabase backend
Future<void> initializeSupabaseBackend() async {
  await SupabaseConfig.initialize();
  print('✅ Supabase backend initialized successfully');
}

// Helper functions for common database operations
class SupabaseHelper {
  
  // Get current user
  static User? get currentUser => supabase.auth.currentUser;
  
  // Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;
  
  // Get user ID
  static String? get currentUserId => currentUser?.id;
  
  // Common database queries
  static SupabaseQueryBuilder get users => supabase.from('users');
  static SupabaseQueryBuilder get clubs => supabase.from('clubs');
  static SupabaseQueryBuilder get tournaments => supabase.from('tournaments');
  static SupabaseQueryBuilder get matches => supabase.from('matches');
  static SupabaseQueryBuilder get notifications => supabase.from('notifications');
  static SupabaseQueryBuilder get leaderboards => supabase.from('leaderboards');
  static SupabaseQueryBuilder get challenges => supabase.from('challenges');
  static SupabaseQueryBuilder get tournamentParticipants => supabase.from('tournament_participants');
  static SupabaseQueryBuilder get chatMessages => supabase.from('chat_messages');
  static SupabaseQueryBuilder get playerStatistics => supabase.from('player_statistics');
  static SupabaseQueryBuilder get clubMemberships => supabase.from('club_memberships');
  
  // Storage buckets
  static SupabaseStorageClient get storage => supabase.storage;
  static String getPublicUrl(String bucket, String path) {
    return storage.from(bucket).getPublicUrl(path);
  }
  
  // Real-time subscriptions
  static RealtimeChannel createChannel(String channelName) {
    return supabase.channel(channelName);
  }
}

// Error handling
class SupabaseException implements Exception {
  final String message;
  final dynamic originalError;
  
  const SupabaseException(this.message, [this.originalError]);
  
  @override
  String toString() => 'SupabaseException: $message';
}

// Common error handler
void handleSupabaseError(dynamic error, [String? context]) {
  final contextStr = context != null ? '[$context] ' : '';
  print('❌ ${contextStr}Supabase Error: $error');
}

// Migration helper functions to gradually replace Firebase calls
class MigrationHelper {
  
  // Convert Firestore-style where clauses to Supabase filters
  static PostgrestFilterBuilder applyWhere(
    PostgrestFilterBuilder query,
    String field,
    dynamic operator,
    dynamic value,
  ) {
    switch (operator) {
      case '==':
        return query.eq(field, value);
      case '!=':
        return query.neq(field, value);
      case '>':
        return query.gt(field, value);
      case '>=':
        return query.gte(field, value);
      case '<':
        return query.lt(field, value);
      case '<=':
        return query.lte(field, value);
      case 'in':
        return query.inFilter(field, value as List);
      case 'array-contains':
        return query.contains(field, value);
      default:
        throw SupabaseException('Unsupported operator: $operator');
    }
  }
  
  // Convert Firestore-style ordering to Supabase
  static PostgrestTransformBuilder applyOrderBy(
    PostgrestFilterBuilder query,
    String field, {
    bool descending = false,
  }) {
    return query.order(field, ascending: !descending);
  }
  
  // Apply limit
  static PostgrestTransformBuilder applyLimit(
    PostgrestFilterBuilder query,
    int limit,
  ) {
    return query.limit(limit);
  }
}