import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../model/analysis_model.dart';

class HistoryService {
  static const String _historyKey = 'resume_analysis_history';
  static const int _maxHistoryItems = 50; // Maximum items to keep in history

  // Save a new analysis to history
  Future<void> saveAnalysis(AnalysisModel analysis) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getHistory();

      // Keep only last _maxHistoryItems analyses
      if (history.length >= _maxHistoryItems) {
        history.removeLast();
      }

      history.insert(0, analysis); // Add new at beginning
      await prefs.setString(
        _historyKey,
        jsonEncode(history.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error saving analysis: $e');
      rethrow;
    }
  }

  // Retrieve all history items
  Future<List<AnalysisModel>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);
      if (historyJson == null) return [];

      final historyList = jsonDecode(historyJson) as List<dynamic>;
      return historyList
          .map((item) => AnalysisModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error parsing history: $e');
      return [];
    }
  }

  Future<AnalysisModel?> getAnalysisById(String timestamp) async {
    try {
      final history = await getHistory();
      final targetTime = DateTime.parse(timestamp);
      try {
        return history.firstWhere(
          (item) =>
              item.timestamp.toIso8601String() == timestamp ||
              item.timestamp == targetTime,
        );
      } catch (e) {
        return null;
      }
    } catch (e) {
      debugPrint('Error getting analysis by ID: $e');
      return null;
    }
  }

  Future<void> deleteAnalysis(String timestamp) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getHistory();

      DateTime? targetTime;
      try {
        targetTime = DateTime.parse(timestamp);
      } catch (e) {
        debugPrint('Error parsing timestamp: $e');
      }

      // Create new list without the item to delete
      final updatedHistory =
          history.where((item) {
            if (item.timestamp.toIso8601String() == timestamp) return false;
            if (targetTime != null && item.timestamp == targetTime)
              return false;
            return true;
          }).toList();

      await prefs.setString(
        _historyKey,
        jsonEncode(updatedHistory.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error deleting analysis: $e');
      rethrow;
    }
  }

  // Clear all history
  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      debugPrint('Error clearing history: $e');
      rethrow;
    }
  }
}
