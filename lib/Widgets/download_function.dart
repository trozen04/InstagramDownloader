import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import 'common_widgets.dart';

Future<void> downloadFile(BuildContext context, String url) async {
  final status = await Permission.storage.request();
  if (status.isGranted) {
    final dir = await getExternalStorageDirectory();
    final filePath = '${dir!.path}/video.mp4';
    try {
      await Dio().download(url, filePath);
      showTopSnackBar(context, 'File saved to: $filePath', true);
      developer.log('✅ File saved to: $filePath');
    } catch (e) {
      showTopSnackBar(context, '❌ Download failed: $e', false);
    }
  } else {
    showTopSnackBar(context, '❌ Storage permission denied', false);
  }
}
