import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier() : super(null) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    final currentEmail = prefs.getString('current_user_email');
    
    if (userJson != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(userJson);
        final user = UserModel.fromJson(decoded);
        // Verify it's the current user
        if (currentEmail == null || user.email == currentEmail) {
          state = user;
        } else {
          state = null;
        }
      } catch (e) {
        // If parsing fails, user data is invalid
        state = null;
      }
    }
  }

  Future<void> _saveUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (state != null) {
      final userJson = jsonEncode(state!.toJson());
      await prefs.setString('user_data', userJson);
    } else {
      await prefs.remove('user_data');
    }
  }

  Future<void> setUser(UserModel user) async {
    state = user;
    await _saveUser();
    // Save user ID to preferences for quick access
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_id', user.id);
    await prefs.setString('current_user_email', user.email);
  }
  
  Future<void> loadUserById(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(userJson);
        final user = UserModel.fromJson(decoded);
        if (user.id == userId) {
          state = user;
        }
      } catch (e) {
        state = null;
      }
    }
  }

  Future<void> updateUser(UserModel user) async {
    state = user;
    await _saveUser();
  }

  Future<void> clearUser() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('current_user_id');
    await prefs.remove('current_user_email');
    await prefs.setBool('is_logged_in', false);
  }

  Future<void> updateLastLogin() async {
    if (state != null) {
      state = state!.copyWith(lastLoginAt: DateTime.now());
      await _saveUser();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user_email', state!.email);
    }
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  return UserNotifier();
});

