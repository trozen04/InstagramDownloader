import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'common_widgets.dart';
import 'package:instagram_downloader_project/Utils/shared_prefs.dart'; // Import SharedPrefs

Future<bool> downloadFileToPublicFolder(BuildContext context, String url, {Function(double)? onProgress, String? thumbnail}) async {
  bool isGranted = false;

  if (Platform.isAndroid) {
    if (await Permission.manageExternalStorage.isGranted || await Permission.storage.isGranted) {
      isGranted = true;
    } else {
      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        isGranted = true;
      } else {
        await openAppSettings();
      }
    }
  }

  if (isGranted) {
    final publicDirPath = '/storage/emulated/0/Download';
    final fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final filePath = '$publicDirPath/$fileName';

    try {
      await Dio().download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            onProgress?.call(progress);
          }
        },
      );

      scanMediaFile(filePath); // Notify media scanner

      // Save to history
      await SharedPrefs().saveDownload(
        title: fileName, // Use fileName or a custom title
        timestamp: DateTime.now().toString(),
        thumbnail: thumbnail!, // Provide thumbnail URL if available
        downloadLink: url,
        type: 'video', // Adjust based on file type
        filePath: filePath, // Save the file path
      );

      showTopSnackBar(context, 'File saved to: $filePath', true);
      developer.log('✅ File saved to: $filePath');
      return true;
    } catch (e) {
      developer.log('❌ Download failed: $e');
      showTopSnackBar(context, '❌ Download failed: $e', false);
      return false;
    }
  } else {
    showTopSnackBar(context, '❌ Storage permission denied. Please allow access.', false);
    await openManageAllFilesPermission();
    return false;
  }
}

Future<void> openManageAllFilesPermission() async {
  final intent = AndroidIntent(
    action: 'android.settings.MANAGE_APP_ALL_FILES_ACCESS_PERMISSION',
    data: 'package:com.example.instagram_downloader_project.instagram_downloader_project',
    flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
  );
  await intent.launch();
}

void scanMediaFile(String path) {
  final intent = AndroidIntent(
    action: 'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
    data: Uri.file(path).toString(),
    flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
  );
  intent.launch();
}