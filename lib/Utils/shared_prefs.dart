import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPrefs {
  static const String _historyKey = 'download_history';

  // Save a download to history
  Future<void> saveDownload(String title, String timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, String>> history = await getHistory();
    history.add({'title': title, 'timestamp': timestamp});
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