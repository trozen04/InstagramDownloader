import 'package:flutter/material.dart';
import 'package:instagram_downloader_project/Utils/f_text_style.dart';
import 'package:instagram_downloader_project/Utils/flutter_color_themes.dart';
import 'package:instagram_downloader_project/Utils/shared_prefs.dart';
import 'package:instagram_downloader_project/Widgets/common_widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, String>> downloadHistory = [];
  final SharedPrefs _sharedPrefs = SharedPrefs();

  @override
  void initState() {
    super.initState();
    _loadDownloadHistory();
  }

  Future<void> _loadDownloadHistory() async {
    final history = await _sharedPrefs.getHistory();
    setState(() {
      downloadHistory = history.reversed.toList(); // Newest first
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Download History', style: FTextStyle.heading(context)),
        backgroundColor: AppColors.my_profile_bg_color,
      ),
      body: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        child: downloadHistory.isEmpty
            ? Center(
          child: Text(
            'No download history',
            style: FTextStyle.body(context).copyWith(color: AppColors.greyText),
          ),
        )
            : ListView.builder(
          itemCount: downloadHistory.length,
          itemBuilder: (context, index) {
            final item = downloadHistory[index];
            return MediaCard(
              title: item['title']!,
              subtitle: item['timestamp']!,
            );
          },
        ),
      ),
    );
  }
}