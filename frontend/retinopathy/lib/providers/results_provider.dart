import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/result_model.dart';
import '../models/user_model.dart';
import 'user_provider.dart';

class ResultsNotifier extends StateNotifier<List<ResultModel>> {
  final Ref ref;
  ResultsNotifier(this.ref) : super([]) {
    _loadResults();
    // Reload results when user changes
    ref.listen<UserModel?>(userProvider, (previous, next) {
      _loadResults();
    });
  }

  Future<void> _loadResults() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = ref.read(userProvider);
    if (currentUser == null) {
      state = [];
      return;
    }
    
    // Load all results from storage
    final resultsJson = prefs.getString('results');
    if (resultsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(resultsJson);
        final allResults = decoded.map((json) => ResultModel.fromJson(json)).toList();
        // Filter results for current user
        state = allResults.where((r) => r.userId == currentUser.id).toList();
      } catch (e) {
        state = [];
      }
    } else {
      state = [];
    }
  }
  
  // Public method to reload results
  Future<void> reload() async {
    await _loadResults();
  }

  Future<void> _saveResults() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = ref.read(userProvider);
    if (currentUser == null) return;
    
    // Load all results
    final resultsJson = prefs.getString('results');
    List<ResultModel> allResults = [];
    if (resultsJson != null) {
      final List<dynamic> decoded = jsonDecode(resultsJson);
      allResults = decoded.map((json) => ResultModel.fromJson(json)).toList();
    }
    
    // Remove old results for this user and add new ones
    allResults.removeWhere((r) => r.userId == currentUser.id);
    allResults.addAll(state);
    
    // Save all results
    final allResultsJson = jsonEncode(allResults.map((r) => r.toJson()).toList());
    await prefs.setString('results', allResultsJson);
  }

  Future<void> addResult(ResultModel result) async {
    state = [result, ...state];
    await _saveResults();
  }

  Future<void> deleteResult(String id) async {
    state = state.where((r) => r.id != id).toList();
    await _saveResults();
  }

  Future<void> clearAllResults() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = ref.read(userProvider);
    
    if (currentUser == null) {
      state = [];
      await prefs.remove('results');
      return;
    }
    
    // Load all results
    final resultsJson = prefs.getString('results');
    if (resultsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(resultsJson);
        final allResults = decoded.map((json) => ResultModel.fromJson(json)).toList();
        // Remove only current user's results
        allResults.removeWhere((r) => r.userId == currentUser.id);
        // Save remaining results
        final remainingResultsJson = jsonEncode(allResults.map((r) => r.toJson()).toList());
        await prefs.setString('results', remainingResultsJson);
      } catch (e) {
        // If error, just clear all
        await prefs.remove('results');
      }
    }
    
    state = [];
  }

  ResultModel? getLatestResult() {
    if (state.isEmpty) return null;
    return state.first;
  }
}

final resultsProvider = StateNotifierProvider<ResultsNotifier, List<ResultModel>>((ref) {
  return ResultsNotifier(ref);
});

