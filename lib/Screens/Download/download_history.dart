import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:instagram_downloader_project/Utils/constants.dart';
import 'package:instagram_downloader_project/Utils/f_text_style.dart';
import 'package:instagram_downloader_project/Utils/flutter_color_themes.dart';
import 'package:instagram_downloader_project/Utils/shared_prefs.dart';
import 'package:instagram_downloader_project/Widgets/Advertisement/BannerAdWidget.dart';
import 'package:instagram_downloader_project/Widgets/common_widgets.dart';
import 'package:instagram_downloader_project/Widgets/download_function.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';

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

      downloadHistory = history.toList(); // Newest first
      developer.log('download: $downloadHistory');
    });
  }

  Future<bool> _requestStoragePermission() async {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        showTopSnackBar(context, 'Storage permission denied.', false);
        await openManageAllFilesPermission();
        return false;
      }
    }
    return true;
  }

  // Function to open a file
  Future<void> _openFile(String? filePath) async {
    if (filePath == null || filePath.isEmpty) {
      showTopSnackBar(context, 'File path not found.', false);
      return;
    }

    final file = File(filePath);
    if (!await file.exists()) {
      showTopSnackBar(context, 'File not found at $filePath.', false);
      return;
    }

    bool hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      return;
    }

    try {
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) {
        showTopSnackBar(context, 'Could not open file: ${result.message}', false);
      }
    } catch (e) {
      showTopSnackBar(context, 'Error opening file', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Download History', style: FTextStyle.heading(context).copyWith(color: Colors.white)),
        backgroundColor: AppColors.brandNew,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () async {
              final confirm = await showDeleteConfirmationDialog(context);
              if (!confirm) return;

              bool hasPermission = await _requestStoragePermission();
              if (hasPermission) {
                await SharedPrefs().clearHistory();
                setState(() {
                  downloadHistory = [];
                });
                showTopSnackBar(context, 'History and files cleared.', true);
              }
            },

          ),
          SizedBox(width: width * 0.035),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.035, vertical: height * 0.01),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            downloadHistory.isEmpty
                ? Center(
              child: Text(
                'No download history',
                style: FTextStyle.body(context).copyWith(color: AppColors.greyText),
              ),
            )
                : Expanded(
              child: ListView.builder(
                itemCount: downloadHistory.length,
                itemBuilder: (context, index) {
                  final item = downloadHistory[index];
                  return GestureDetector(
                    onTap: () => _openFile(item['filePath']), // Open file on tap
                    child: MediaCard(
                      title: item['title']!,
                      subtitle: item['timestamp']!,
                      thumbnail: item['thumbnail'],
                    ),
                  );
                },
              ),
            ),
            BannerAdWidget(
              adUnitId: AdUnits.BannerBasic,
              alignment: Alignment.bottomCenter,
            ),
          ],
        ),
      ),
    );
  }
}