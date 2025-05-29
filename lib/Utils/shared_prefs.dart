import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPrefs {
  static const String _historyKey = 'download_history';
  static const int _maxHistoryLength = 20;

  // Save a download to history
  Future<void> saveDownload({
    required String title,
    required String timestamp,
    required String thumbnail,
    required String downloadLink,
    required String type,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, String>> history = await getHistory();

    // Create new history entry
    final newEntry = {
      'title': title,
      'timestamp': timestamp,
      'thumbnail': thumbnail,
      'downloadLink': downloadLink,
      'type': type,
    };

    developer.log('new: $newEntry');

    // Add new entry and maintain only the most recent 20
    history.insert(0, newEntry); // Insert at the beginning
    if (history.length > _maxHistoryLength) {
      history = history.sublist(0, _maxHistoryLength);
    }

    await prefs.setString(_historyKey, jsonEncode(history));
  }

  // Retrieve download history
  Future<List<Map<String, String>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(_historyKey);
    if (historyJson != null) {
      final List<dynamic> historyList = jsonDecode(historyJson);
      return historyList.map((item) => Map<String, String>.from(item)).toList();
    }
    return [];
  }
}