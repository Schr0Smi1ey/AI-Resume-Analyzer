import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../model/analysis_model.dart';
import 'package:uuid/uuid.dart';

class HistoryService {
  static const String _historyKey = 'resume_analysis_history';
  static const String _migrationKey = 'history_migration_done';
  static const int _maxHistoryItems = 50; // Maximum items to keep in history

  // Perform one-time migration to fix old data
  Future<void> _migrateHistoryData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_migrationKey) == true) {
      return; // Migration already done
    }

    try {
      final historyJson = prefs.getString(_historyKey);
      if (historyJson == null) {
        await prefs.setBool(_migrationKey, true);
        return;
      }

      final historyList = jsonDecode(historyJson) as List<dynamic>;
      final updatedHistory = <AnalysisModel>[];
      for (var item in historyList) {
        try {
          final jsonItem = item as Map<String, dynamic>;
          // Skip if no ID or invalid ID
          if (jsonItem['id'] == null || (jsonItem['id'] as String).isEmpty) {
            jsonItem['id'] = const Uuid().v4();
          }
          final analysis = AnalysisModel.fromJson(jsonItem);
          updatedHistory.add(analysis);
        } catch (e) {
          debugPrint('Skipping invalid history item during migration: $e');
          continue;
        }
      }

      // Save updated history
      await prefs.setString(
        _historyKey,
        jsonEncode(updatedHistory.map((e) => e.toJson()).toList()),
      );
      await prefs.setBool(_migrationKey, true);
      debugPrint('History migration completed successfully');
    } catch (e) {
      debugPrint('Error during history migration: $e');
      // Clear history if migration fails to prevent persistent errors
      await prefs.remove(_historyKey);
      await prefs.setBool(_migrationKey, true);
    }
  }

  // Save a new analysis to history
  Future<void> saveAnalysis(AnalysisModel analysis) async {
    try {
      await _migrateHistoryData();
      final prefs = await SharedPreferences.getInstance();
      final history = await getHistory();

      // Remove any existing item with the same ID
      history.removeWhere((item) => item.id == analysis.id);

      if (history.length >= _maxHistoryItems) {
        history.removeLast();
      }

      history.insert(0, analysis);
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
      await _migrateHistoryData(); // Ensure migration is done
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);
      if (historyJson == null) return [];

      final historyList = jsonDecode(historyJson) as List<dynamic>;
      final validHistory = <AnalysisModel>[];
      for (var item in historyList) {
        try {
          final analysis = AnalysisModel.fromJson(item as Map<String, dynamic>);
          if (analysis.id.isNotEmpty && analysis.id.length >= 36) {
            validHistory.add(analysis);
          } else {
            debugPrint('Skipping history item with invalid ID: ${analysis.id}');
          }
        } catch (e) {
          debugPrint('Skipping invalid history item: $e');
          continue;
        }
      }
      return validHistory;
    } catch (e) {
      debugPrint('Error parsing history: $e');
      return [];
    }
  }

  Future<AnalysisModel?> getAnalysisById(String id) async {
    try {
      final history = await getHistory();
      try {
        return history.firstWhere((item) => item.id == id);
      } catch (e) {
        return null;
      }
    } catch (e) {
      debugPrint('Error getting analysis by ID: $e');
      return null;
    }
  }

  Future<void> deleteAnalysis(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getHistory();

      // Create new list without the item to delete
      final updatedHistory = history.where((item) => item.id != id).toList();

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
