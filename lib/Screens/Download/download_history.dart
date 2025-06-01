import 'package:flutter/material.dart';
import 'package:instagram_downloader_project/Utils/constants.dart';
import 'package:instagram_downloader_project/Utils/f_text_style.dart';
import 'package:instagram_downloader_project/Utils/flutter_color_themes.dart';
import 'package:instagram_downloader_project/Utils/shared_prefs.dart';
import 'package:instagram_downloader_project/Widgets/Advertisement/BannerAdWidget.dart';
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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Download History', style: FTextStyle.heading(context)),
        backgroundColor: AppColors.my_profile_bg_color,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.brandNew),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.brandNew,),
            onPressed: () async {
              await SharedPrefs().clearHistory(); // Implement this in SharedPrefs
              Navigator.pop(context);
              showTopSnackBar(context, 'History data has been cleared.', true);
            },
          ),
          SizedBox(width: width * 0.035,)
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.035, vertical: height * 0.01),
        child: Column(
          children: [
            downloadHistory.isEmpty
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
                  thumbnail: item['thumbnail'],
                );
              },
            ),
            BannerAdWidget(
              adUnitId: AdUnits.BannerBasic, // Test Banner Ad Unit ID
              alignment: Alignment.bottomCenter,
            ),
          ],
        ),
      ),
    );
  }
}