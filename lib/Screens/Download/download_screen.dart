import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:instagram_downloader_project/Screens/APIBloc/insta_downloader_bloc.dart';
import 'package:instagram_downloader_project/Utils/f_text_style.dart';
import 'package:instagram_downloader_project/Utils/flutter_color_themes.dart';
import 'package:instagram_downloader_project/Widgets/common_widgets.dart';
import 'package:instagram_downloader_project/Utils/shared_prefs.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram_downloader_project/Widgets/download_function.dart';

class DownloadScreen extends StatefulWidget {
  final String url;
  final String type;

  const DownloadScreen({super.key, required this.url, required this.type});

  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}


class _DownloadScreenState extends State<DownloadScreen> {
  double _progress = 0.0;
  bool _isDownloading = false;
  String _status = 'Downloading Video...';
  final SharedPrefs _sharedPrefs = SharedPrefs();
  String thumbnail = "";
  String downloadLink = "";
  String type = "";

  @override
  void initState() {
    super.initState();
  }

  Future<void> _simulateDownload(String downloadLink) async {
    setState(() {
      _isDownloading = true;
      _status = 'Downloading Video...';
    });

    bool downloadSuccess = await downloadFileToPublicFolder(
      context,
      downloadLink,
      onProgress: (progress) {
        setState(() {
          _progress = progress;
        });
      },
    );

    if (downloadSuccess) {
      // Save to history only if download was successful
      final String title = 'Video ${DateTime.now().millisecondsSinceEpoch}';
      final String timestamp = DateTime.now().toString().substring(0, 10);
      await _sharedPrefs.saveDownload(
        title: title,
        timestamp: timestamp,
        thumbnail: thumbnail,
        downloadLink: downloadLink,
        type: type,
      );

      setState(() {
        _isDownloading = false;
        _status = 'Download Complete!';
        _progress = 1.0;
      });

      // Navigate back to home after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    } else {
      setState(() {
        _isDownloading = false;
        _status = 'Download Failed!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Downloading Your Video', style: FTextStyle.heading(context)),
        backgroundColor: AppColors.my_profile_bg_color,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.heading),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: height * 0.01,
          horizontal: width * 0.035,
        ),
        child: BlocProvider(
          create: (context) =>
          InstaDownloaderBloc()
            ..add(InstaDownloaderEventHandler(url: widget.url, type: widget.type)),
          child: BlocListener<InstaDownloaderBloc, InstaDownloaderState>(
            listener: (context, state) async {
              if (state is InstaDownloaderLoadingState) {
                setState(() {
                  _isDownloading = true;
                  _status = 'Fetching Video...';
                });
              } else if (state is InstaDownloaderSuccessState) {
                final resultData = state.responseData;
                developer.log('resultData: $resultData');
                if (resultData.isNotEmpty && resultData[0] is Map) {
                  final data = resultData[0];
                  developer.log('data: $data');
                  setState(() {
                    thumbnail = data?['thumbnail'];
                    downloadLink = data?['url'];
                    type = data.containsKey('type') ? data['type'] : 'Video';
                  });
                  showTopSnackBar(context, 'Starting Download...', true);

                  if (downloadLink != "") {
                    await _simulateDownload(downloadLink); // Start actual download
                  }
                  developer.log('thumbnail: $thumbnail \n downloadLink: $downloadLink \n type: $type');
                }
              } else if (state is InstaDownloaderErrorState) {
                developer.log('errorMessage: ${state.errorMessage}');
                setState(() {
                  _isDownloading = false;
                  _status = 'Error Occurred!';
                });
                showTopSnackBar(context, state.errorMessage, false);
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: width * 0.8,
                  height: height * 0.3,
                  decoration: BoxDecoration(
                    color: AppColors.previewBG,
                    borderRadius: BorderRadius.circular(12),
                    image: thumbnail != ""
                        ? DecorationImage(
                      image: NetworkImage(thumbnail),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: thumbnail == ""
                      ? const Center(
                    child: Icon(
                      Icons.videocam,
                      size: 50,
                      color: AppColors.preview,
                    ),
                  )
                      : null,
                ),
                SizedBox(height: height * 0.03),
                Text(_status, style: FTextStyle.subheading(context)),
                SizedBox(height: height * 0.02),
                LinearProgressIndicator(
                  value: _progress,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.linearprogressindicatorcolor,
                  ),
                  backgroundColor: AppColors.indicator,
                ),
                SizedBox(height: height * 0.03),
                if (_isDownloading)
                  CustomButton(
                    text: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}