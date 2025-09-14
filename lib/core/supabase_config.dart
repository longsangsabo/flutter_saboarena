import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration and initialization for Sabo Arena
class SupabaseConfig {
  // TODO: Replace with your actual Supabase project credentials
  static const String supabaseUrl = 'https://skzirkhzwhyqmnfyytcl.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNremlya2h6d2h5cW1uZnl5dGNsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc3NDM3MzUsImV4cCI6MjA3MzMxOTczNX0._0Ic0SL4FZVMennTXmOzIp2KBOCwRagpbRXaWhZJI24';
  
  // Service role key for admin operations (use carefully)
  static const String supabaseServiceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNremlya2h6d2h5cW1uZnl5dGNsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1Nzc0MzczNSwiZXhwIjoyMDczMzE5NzM1fQ.xIlkzXWPUq6Kwcs__XEduFZnCEi_y4up8Hd536VDmy0';
  
  /// Initialize Supabase client
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true, // Set to false in production
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
      storageOptions: const StorageClientOptions(
        retryAttempts: 10,
      ),
    );
  }
  
  /// Get the Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;
  
  /// Get the authentication client
  static GoTrueClient get auth => client.auth;
  
  /// Get database query builder
  static SupabaseQueryBuilder from(String table) => client.from(table);
  
  /// Get storage client
  static SupabaseStorageClient get storage => client.storage;
  
  /// Get real-time client
  static RealtimeClient get realtime => client.realtime;
  
  /// Current authenticated user
  static User? get currentUser => auth.currentUser;
  
  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;
  
  /// Listen to authentication state changes
  static Stream<AuthState> get authStateChanges => auth.onAuthStateChange;
}