import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';

/// Authentication service using Supabase Auth
class SupabaseAuthService {
  static final _client = SupabaseConfig.client;

  /// Sign up with email and password
  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: userData,
      );
      
      // Create user profile after successful signup
      if (response.user != null) {
        await _createUserProfile(response.user!, userData);
      }
      
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with email and password
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with Google OAuth
  static Future<bool> signInWithGoogle() async {
    try {
      return await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.saboarena://login-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print('Error signing in with Google: $e');
      return false;
    }
  }

  /// Sign in with Apple OAuth (iOS)
  static Future<bool> signInWithApple() async {
    try {
      return await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.saboarena://login-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print('Error signing in with Apple: $e');
      return false;
    }
  }

  /// Sign out current user
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Send password reset email
  static Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.saboarena://reset-password/',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Update user password
  static Future<UserResponse> updatePassword(String newPassword) async {
    try {
      return await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Update user email
  static Future<UserResponse> updateEmail(String newEmail) async {
    try {
      return await _client.auth.updateUser(
        UserAttributes(email: newEmail),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get current user
  static User? get currentUser => _client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Get current user ID
  static String? get currentUserId => currentUser?.id;

  /// Listen to authentication state changes
  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Refresh current session
  static Future<AuthResponse> refreshSession() async {
    try {
      return await _client.auth.refreshSession();
    } catch (e) {
      rethrow;
    }
  }

  /// Create user profile in database after successful signup
  static Future<void> _createUserProfile(User user, Map<String, dynamic> userData) async {
    try {
      await _client.from('users').insert({
        'auth_id': user.id,
        'email': user.email,
        'full_name': userData['full_name'],
        'display_name': userData['display_name'] ?? userData['full_name'],
        'username': userData['username'],
        'photo_url': user.userMetadata?['avatar_url'],
        'phone_number': user.phone,
        'preferred_language': userData['preferred_language'] ?? 'en',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error creating user profile: $e');
      // Don't rethrow here as the signup was successful
    }
  }

  /// Handle OAuth callback
  static Future<void> handleOAuthCallback(String url) async {
    try {
      await _client.auth.getSessionFromUrl(Uri.parse(url));
    } catch (e) {
      rethrow;
    }
  }

  /// Check if email exists
  static Future<bool> checkEmailExists(String email) async {
    try {
      final response = await _client
          .from('users')
          .select('email')
          .eq('email', email)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Check if username exists
  static Future<bool> checkUsernameExists(String username) async {
    try {
      final response = await _client
          .from('users')
          .select('username')
          .eq('username', username.toLowerCase())
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Send email verification
  static Future<void> sendEmailVerification() async {
    try {
      final user = currentUser;
      if (user != null) {
        await _client.auth.resend(
          type: OtpType.signup,
          email: user.email,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Verify OTP for email confirmation
  static Future<AuthResponse> verifyOTP({
    required String email,
    required String token,
    required OtpType type,
  }) async {
    try {
      return await _client.auth.verifyOTP(
        email: email,
        token: token,
        type: type,
      );
    } catch (e) {
      rethrow;
    }
  }
}