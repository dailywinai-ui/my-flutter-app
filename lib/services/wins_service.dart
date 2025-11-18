import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/daily_win.dart';
import '../models/major_goal.dart';
import '../models/win.dart';
import './auth_service.dart';
import './supabase_service.dart';

class WinsService {
  static WinsService? _instance;
  static WinsService get instance => _instance ??= WinsService._();

  WinsService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  /// Get all daily wins for current user
  Future<List<DailyWin>> getDailyWins({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user');
      }

      // ✅ CORRECT: Apply all filters first, then chain modifiers
      var query = _client.from('daily_wins').select('''
            id,
            description,
            goal_id,
            user_id,
            win_date,
            mood_rating,
            reflection,
            created_at,
            updated_at
          ''').eq('user_id', currentUser.id);

      // Apply date filters if provided
      if (startDate != null) {
        query =
            query.gte('win_date', startDate.toIso8601String().split('T')[0]);
      }

      if (endDate != null) {
        query = query.lte('win_date', endDate.toIso8601String().split('T')[0]);
      }

      // Apply modifiers after all filters
      final response =
          await query.order('win_date', ascending: false).limit(limit);

      return response.map<DailyWin>((data) => DailyWin.fromJson(data)).toList();
    } catch (error) {
      throw Exception('Failed to fetch daily wins: $error');
    }
  }

  /// Create a new daily win
  Future<DailyWin> createDailyWin({
    required String description,
    required String goalId,
    DateTime? winDate,
    int? moodRating,
    String? reflection,
  }) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user');
      }

      final data = {
        'description': description,
        'goal_id': goalId,
        'user_id': currentUser.id,
        'win_date': (winDate ?? DateTime.now()).toIso8601String().split('T')[0],
        'mood_rating': moodRating,
        'reflection': reflection,
      };

      final response =
          await _client.from('daily_wins').insert(data).select().single();

      return DailyWin.fromJson(response);
    } catch (error) {
      throw Exception('Failed to create daily win: $error');
    }
  }

  /// Update an existing daily win
  Future<DailyWin> updateDailyWin({
    required String winId,
    String? description,
    int? moodRating,
    String? reflection,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};

      if (description != null) updateData['description'] = description;
      if (moodRating != null) updateData['mood_rating'] = moodRating;
      if (reflection != null) updateData['reflection'] = reflection;

      // Add updated timestamp
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('daily_wins')
          .update(updateData)
          .eq('id', winId)
          .select()
          .single();

      return DailyWin.fromJson(response);
    } catch (e) {
      print('Error updating daily win: $e');
      throw Exception('Failed to update daily win: $e');
    }
  }

  /// Delete a daily win
  Future<void> deleteDailyWin(String winId) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user');
      }

      await _client
          .from('daily_wins')
          .delete()
          .eq('id', winId)
          .eq('user_id', currentUser.id);
    } catch (error) {
      throw Exception('Failed to delete daily win: $error');
    }
  }

  /// Get all major goals for current user
  Future<List<MajorGoal>> getMajorGoals({bool activeOnly = true}) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user');
      }

      // ✅ CORRECT: Apply all filters first, then chain modifiers
      var query =
          _client.from('major_goals').select().eq('user_id', currentUser.id);

      if (activeOnly) {
        query = query.eq('is_active', true);
      }

      // Apply ordering after all filters
      final response = await query.order('position', ascending: true);

      return response
          .map<MajorGoal>((data) => MajorGoal.fromJson(data))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch major goals: $error');
    }
  }

  /// Create a new major goal
  Future<MajorGoal> createMajorGoal({
    required String title,
    String? description,
  }) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user');
      }

      // Get the next position
      final existingGoals = await getMajorGoals(activeOnly: true);
      final nextPosition = existingGoals.length + 1;

      final data = {
        'title': title,
        'description': description,
        'user_id': currentUser.id,
        'position': nextPosition,
        'is_active': true,
        'is_archived': false,
      };

      final response =
          await _client.from('major_goals').insert(data).select().single();

      return MajorGoal.fromJson(response);
    } catch (error) {
      throw Exception('Failed to create major goal: $error');
    }
  }

  /// Update a major goal
  Future<MajorGoal> updateMajorGoal({
    required String goalId,
    String? title,
    String? description,
  }) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user');
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;

      final response = await _client
          .from('major_goals')
          .update(updateData)
          .eq('id', goalId)
          .eq('user_id', currentUser.id)
          .select()
          .single();

      return MajorGoal.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update major goal: $error');
    }
  }

  /// Archive a major goal
  Future<MajorGoal> archiveMajorGoal(String goalId) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user');
      }

      final response = await _client
          .from('major_goals')
          .update({
            'is_active': false,
            'is_archived': true,
            'archived_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', goalId)
          .eq('user_id', currentUser.id)
          .select()
          .single();

      return MajorGoal.fromJson(response);
    } catch (error) {
      throw Exception('Failed to archive major goal: $error');
    }
  }

  /// Get all general wins for current user
  Future<List<Win>> getWins({
    DateTime? startDate,
    DateTime? endDate,
    WinCategory? category,
    int limit = 50,
  }) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user');
      }

      // ✅ CORRECT: Apply all filters first, then chain modifiers
      var query = _client.from('wins').select().eq('user_id', currentUser.id);

      // Apply date filters if provided
      if (startDate != null) {
        query =
            query.gte('win_date', startDate.toIso8601String().split('T')[0]);
      }

      if (endDate != null) {
        query = query.lte('win_date', endDate.toIso8601String().split('T')[0]);
      }

      if (category != null) {
        final categoryString = category.name;
        query = query.eq('category', categoryString);
      }

      // Apply modifiers after all filters
      final response =
          await query.order('created_at', ascending: false).limit(limit);

      return response.map<Win>((data) => Win.fromJson(data)).toList();
    } catch (error) {
      throw Exception('Failed to fetch wins: $error');
    }
  }

  /// Create a new general win
  Future<Win> createWin({
    required String text,
    DateTime? winDate,
    String? goalId,
    WinCategory? category,
    int? mood,
    String? reflection,
  }) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user');
      }

      final data = {
        'text': text,
        'user_id': currentUser.id,
        'win_date': (winDate ?? DateTime.now()).toIso8601String().split('T')[0],
        'goal_id': goalId,
        'category': category?.name,
        'mood': mood,
        'reflection': reflection,
      };

      final response =
          await _client.from('wins').insert(data).select().single();

      return Win.fromJson(response);
    } catch (error) {
      throw Exception('Failed to create win: $error');
    }
  }

  /// Update a general win
  Future<Win> updateWin({
    required String winId,
    String? text,
    WinCategory? category,
    int? mood,
    String? reflection,
  }) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user');
      }

      final updateData = <String, dynamic>{};

      if (text != null) updateData['text'] = text;
      if (category != null) updateData['category'] = category.name;
      if (mood != null) updateData['mood'] = mood;
      if (reflection != null) updateData['reflection'] = reflection;

      final response = await _client
          .from('wins')
          .update(updateData)
          .eq('id', winId)
          .eq('user_id', currentUser.id)
          .select()
          .single();

      return Win.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update win: $error');
    }
  }

  /// Delete a general win
  Future<void> deleteWin(String winId) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user');
      }

      await _client
          .from('wins')
          .delete()
          .eq('id', winId)
          .eq('user_id', currentUser.id);
    } catch (error) {
      throw Exception('Failed to delete win: $error');
    }
  }

  /// Get wins for today
  Future<List<DailyWin>> getTodaysWins() async {
    final today = DateTime.now();
    return await getDailyWins(
      startDate: today,
      endDate: today,
      limit: 10,
    );
  }

  /// Get statistics for dashboard
  Future<Map<String, int>> getWinsStats() async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user');
      }

      // Get counts for different time periods
      final today = DateTime.now();
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      final monthStart = DateTime(today.year, today.month, 1);

      final todayWins = await getDailyWins(
        startDate: today,
        endDate: today,
        limit: 100,
      );

      final weekWins = await getDailyWins(
        startDate: weekStart,
        endDate: today,
        limit: 200,
      );

      final monthWins = await getDailyWins(
        startDate: monthStart,
        endDate: today,
        limit: 500,
      );

      return {
        'today': todayWins.length,
        'week': weekWins.length,
        'month': monthWins.length,
      };
    } catch (error) {
      return {
        'today': 0,
        'week': 0,
        'month': 0,
      };
    }
  }
}
