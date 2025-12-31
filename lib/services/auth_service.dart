import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';
import './supabase_service.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();

  AuthService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Get current authenticated user
  User? get currentUser => _client.auth.currentUser;

  // Check if user is signed in
  bool get isSignedIn => currentUser != null;

  // Auth state stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      // Check for sign up errors
      if (response.user == null && response.session == null) {
        throw Exception('Sign up failed: No user or session created');
      }

      // Only try to create profile manually if trigger failed and user exists
      if (response.user != null) {
        try {
          // Wait a bit for trigger to complete
          await Future.delayed(const Duration(milliseconds: 1000));

          // Check if profile was created by trigger
          final existingProfile =
              await _client
                  .from('user_profiles')
                  .select('id')
                  .eq('id', response.user!.id)
                  .maybeSingle();

          // If no profile exists, try to create one manually as fallback
          if (existingProfile == null) {
            print('Profile not found, attempting manual creation...');
            await _createUserProfileFallback(response.user!);
          }
        } catch (profileError) {
          // Profile creation is non-critical for sign up success
          print('Profile creation note: $profileError');

          // Try calling the ensure_user_profile function as last resort
          try {
            await _client.rpc(
              'ensure_user_profile',
              params: {
                'user_uuid': response.user!.id,
                'user_email': response.user!.email,
              },
            );
          } catch (rpcError) {
            print('RPC fallback failed: $rpcError');
          }
        }
      }

      return response;
    } on AuthException catch (error) {
      throw Exception('Sign up failed: ${getAuthErrorMessage(error)}');
    } catch (error) {
      throw Exception('Sign up failed: $error');
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Update last seen timestamp
        await _updateLastSeen(response.user!.id);
      }

      return response;
    } catch (error) {
      throw Exception('Sign in failed: $error');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error) {
      throw Exception('Sign out failed: $error');
    }
  }

  /// Get user profile data
  Future<UserProfile?> getUserProfile() async {
    try {
      if (currentUser == null) return null;

      final response =
          await _client
              .from('user_profiles')
              .select()
              .eq('id', currentUser!.id)
              .single();

      return UserProfile.fromJson(response);
    } catch (error) {
      // User profile might not exist yet
      return null;
    }
  }

  /// Update user profile
  Future<UserProfile> updateUserProfile({
    bool? notificationEnabled,
    String? timezone,
  }) async {
    try {
      if (currentUser == null) {
        throw Exception('No authenticated user');
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (notificationEnabled != null) {
        updateData['notification_enabled'] = notificationEnabled;
      }
      if (timezone != null) {
        updateData['timezone'] = timezone;
      }

      final response =
          await _client
              .from('user_profiles')
              .update(updateData)
              .eq('id', currentUser!.id)
              .select()
              .single();

      return UserProfile.fromJson(response);
    } catch (error) {
      throw Exception('Profile update failed: $error');
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      if (currentUser == null) {
        throw Exception('No authenticated user');
      }

      // Delete user profile (this will cascade delete related data)
      await _client.from('user_profiles').delete().eq('id', currentUser!.id);

      // Sign out
      await signOut();
    } catch (error) {
      throw Exception('Account deletion failed: $error');
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo:
            'https://ca.windaily.app/auth/reset', // ← Updated deep link URL
      );
    } catch (error) {
      throw Exception('Failed to send reset email: $error');
    }
  }

  /// Update user password (called from reset password screen)
  Future<void> updatePassword(String newPassword) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user == null) {
        throw Exception('Failed to update password');
      }
    } catch (e) {
      throw Exception('Failed to update password: ${e.toString()}');
    }
  }

  /// Create user profile in database
  Future<void> _createUserProfile(User user) async {
    try {
      await _client.from('user_profiles').insert({
        'id': user.id,
        'email': user.email!,
        'created_at': DateTime.now().toIso8601String(),
        'last_seen_at': DateTime.now().toIso8601String(),
        'notification_enabled': true,
        'timezone': 'UTC',
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (error) {
      // Profile creation might fail if trigger already created it
      // This is okay, we can continue
      print('Profile creation note: $error');
    }
  }

  /// Improved fallback profile creation method
  Future<void> _createUserProfileFallback(User user) async {
    try {
      await _client.from('user_profiles').insert({
        'id': user.id,
        'email': user.email!,
        'created_at': DateTime.now().toIso8601String(),
        'last_seen_at': DateTime.now().toIso8601String(),
        'notification_enabled': true,
        'timezone': 'UTC',
        'updated_at': DateTime.now().toIso8601String(),
      });
      print('Manual profile creation successful');
    } catch (error) {
      print('Manual profile creation failed: $error');

      // If it's a duplicate key error, that's actually good - profile exists
      if (error.toString().contains('duplicate key') ||
          error.toString().contains('already exists')) {
        print('Profile already exists, continuing...');
        return;
      }

      rethrow;
    }
  }

  /// Update last seen timestamp
  Future<void> _updateLastSeen(String userId) async {
    try {
      await _client
          .from('user_profiles')
          .update({
            'last_seen_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (error) {
      // Non-critical, continue silently
      print('Last seen update note: $error');
    }
  }

  /// Check if user should see onboarding after successful authentication
  Future<bool> shouldShowOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // For newly created accounts, always show onboarding initially
      return !(prefs.getBool('seen_onboarding') ?? false);
    } catch (error) {
      return true; // Default to showing onboarding if error
    }
  }

  /// Mark onboarding as seen (called after user completes onboarding)
  Future<void> markOnboardingSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seen_onboarding', true);
    } catch (error) {
      print('Error marking onboarding as seen: $error');
    }
  }

  /// Check if user has completed profile setup
  Future<bool> hasCompletedProfile() async {
    try {
      final profile = await getUserProfile();
      return profile != null;
    } catch (error) {
      return false;
    }
  }

  /// Get error message from AuthException
  String getAuthErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Invalid email or password. Please check your credentials.';
        case 'User already registered':
          return 'An account with this email already exists.';
        case 'Email not confirmed':
          return 'Please check your email and confirm your account.';
        case 'Signup disabled':
          return 'New account registration is currently disabled.';
        case 'Email rate limit exceeded':
          return 'Too many attempts. Please wait before trying again.';
        case 'To signup, please provide your email':
          return 'Please enter a valid email address.';
        case 'Signup requires a valid password':
          return 'Please enter a password with at least 6 characters.';
        case 'User not allowed':
          return 'Registration is not allowed for this email address.';
        default:
          return error.message.contains('permission denied')
              ? 'Unable to create account. Please try again.'
              : error.message;
      }
    }
    return error.toString();
  }
}
