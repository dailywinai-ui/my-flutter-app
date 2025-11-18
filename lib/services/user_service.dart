import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import './auth_service.dart';
import './supabase_service.dart';

class UserService {
  static UserService? _instance;
  static UserService get instance => _instance ??= UserService._();

  UserService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  /// Get all user profiles (admin function)
  Future<List<UserProfile>> getAllUsers({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .order('created_at', ascending: false)
          .limit(limit)
          .range(offset, offset + limit - 1);

      return response
          .map<UserProfile>((data) => UserProfile.fromJson(data))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch users: $error');
    }
  }

  /// Search users by email
  Future<List<UserProfile>> searchUsers(String emailQuery) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .ilike('email', '%$emailQuery%')
          .order('created_at', ascending: false)
          .limit(20);

      return response
          .map<UserProfile>((data) => UserProfile.fromJson(data))
          .toList();
    } catch (error) {
      throw Exception('User search failed: $error');
    }
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user');
      }

      // Get user's data counts
      final winsResponse = await _client
          .from('wins')
          .select('id')
          .eq('user_id', currentUser.id)
          .count();

      final dailyWinsResponse = await _client
          .from('daily_wins')
          .select('id')
          .eq('user_id', currentUser.id)
          .count();

      final goalsResponse = await _client
          .from('major_goals')
          .select('id')
          .eq('user_id', currentUser.id)
          .count();

      return {
        'total_wins': winsResponse.count ?? 0,
        'daily_wins': dailyWinsResponse.count ?? 0,
        'major_goals': goalsResponse.count ?? 0,
      };
    } catch (error) {
      throw Exception('Stats retrieval failed: $error');
    }
  }

  /// Update user preferences
  Future<UserProfile> updateUserPreferences({
    bool? notificationEnabled,
    String? timezone,
  }) async {
    try {
      return await AuthService.instance.updateUserProfile(
        notificationEnabled: notificationEnabled,
        timezone: timezone,
      );
    } catch (error) {
      throw Exception('Preferences update failed: $error');
    }
  }

  /// Get user timezone
  Future<String> getUserTimezone() async {
    try {
      final profile = await AuthService.instance.getUserProfile();
      return profile?.timezone ?? 'UTC';
    } catch (error) {
      return 'UTC'; // Fallback to UTC
    }
  }

  /// Check if user has notifications enabled
  Future<bool> isNotificationEnabled() async {
    try {
      final profile = await AuthService.instance.getUserProfile();
      return profile?.notificationEnabled ?? true;
    } catch (error) {
      return true; // Default to enabled
    }
  }

  /// Update user's last active timestamp
  Future<void> updateLastActive() async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) return;

      await _client.from('user_profiles').update({
        'last_seen_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', currentUser.id);
    } catch (error) {
      // Non-critical operation, fail silently
      print('Last active update note: $error');
    }
  }

  /// Get user profile by ID (admin function)
  Future<UserProfile?> getUserById(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(response);
    } catch (error) {
      return null;
    }
  }

  /// Check if user exists by email
  Future<bool> checkUserExists(String email) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select('id')
          .eq('email', email.toLowerCase())
          .limit(1);

      return response.isNotEmpty;
    } catch (error) {
      return false;
    }
  }

  /// Get recently active users (admin function)
  Future<List<UserProfile>> getRecentlyActiveUsers({
    int limit = 10,
  }) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .not('last_seen_at', 'is', null)
          .order('last_seen_at', ascending: false)
          .limit(limit);

      return response
          .map<UserProfile>((data) => UserProfile.fromJson(data))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch recent users: $error');
    }
  }

  /// Get user count (admin function)
  Future<int> getTotalUserCount() async {
    try {
      final response = await _client.from('user_profiles').select('id').count();

      return response.count ?? 0;
    } catch (error) {
      return 0;
    }
  }
}
