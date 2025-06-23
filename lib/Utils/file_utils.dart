import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> openFile(
    BuildContext context,
    String? filePath, {
      required Future<void> Function() openManageAllFilesPermission,
      required void Function(BuildContext context, String message, bool isSuccess) showTopSnackBar,
    }) async {

  if (filePath == null || filePath.isEmpty) {
    showTopSnackBar(context, 'File path not found.', false);
    return;
  }

  final file = File(filePath);
  if (!await file.exists()) {
    showTopSnackBar(context, 'File not found at $filePath.', false);
    return;
  }

  var status = await Permission.storage.request();
  if (!status.isGranted) {
    status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      showTopSnackBar(context, 'Storage permission denied.', false);
      await openManageAllFilesPermission();
      return;
    }
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
