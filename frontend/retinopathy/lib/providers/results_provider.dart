import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/result_model.dart';
import '../models/user_model.dart';
import 'user_provider.dart';
import '../constants.dart';


import 'package:http/http.dart' as http;

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

    try {
      // First try to fetch from API to get latest data from database
      final uri = Uri.parse('${ApiConstants.historyUrl}?patient_id=${currentUser.id}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> resultsJson = data['results'];
        
        final apiResults = resultsJson.map((json) {
          int severityLevel = 0;
          final drGrade = json['dr_grade'];
          if (drGrade == "Mild") severityLevel = 1;
          else if (drGrade == "Moderate") severityLevel = 2;
          else if (drGrade == "Severe") severityLevel = 3;
          else if (drGrade == "Proliferative DR") severityLevel = 4;

          return ResultModel(
            id: json['image_id'].toString(),
            userId: currentUser.id,
            date: DateTime.parse(json['date']),
            severityLevel: severityLevel,
            confidenceScore: (json['confidence'] as num).toDouble() / 100.0,
            hasDME: false,
            imagePath: json['image_path'], // Note: This is just the filename
          );
        }).toList();

        state = apiResults;
        // Optionally update local cache too
        await _saveResults();
        return;
      }
    } catch (e) {
      print("Error fetching history from API: $e");
      // Fallback to local storage if API fails
    }
    
    // Load all results from storage (fallback)
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

