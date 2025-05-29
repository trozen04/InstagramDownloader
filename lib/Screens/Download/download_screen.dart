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
  const DownloadScreen({super.key, required this.url});

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

  Future<void> _simulateDownload() async {
    setState(() {
      _isDownloading = true;
    });

    // Simulate download process
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _progress = i / 100;
      });
    }

    // Save mock download to history
    final String url = ModalRoute.of(context)!.settings.arguments as String;
    final String title = 'Video ${DateTime.now().millisecondsSinceEpoch}';
    final String timestamp = DateTime.now().toString().substring(0, 10);
    await _sharedPrefs.saveDownload(title, timestamp);

    setState(() {
      _isDownloading = false;
      _status = 'Download Complete!';
    });

    // Navigate back to home after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
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
          onTap: () {
            Navigator.pop(context);
          },
            child: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.heading,)),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: height * 0.01,
          horizontal: width * 0.04,
        ),
        child: BlocProvider(
          create: (context) =>
              InstaDownloaderBloc()
                ..add(InstaDownloaderEventHandler(url: widget.url)),
          child: BlocListener<InstaDownloaderBloc, InstaDownloaderState>(
            listener: (context, state) {
              if (state is InstaDownloaderLoadingState) {
                setState(() {
                  _isDownloading = true;
                  _simulateDownload();
                });
              } else if (state is InstaDownloaderSuccessState) {
                final resultData = state.responseData;
                developer.log('resultData: $resultData');
                if (resultData.isNotEmpty && resultData[0] is Map) {
                  final data = resultData[0];
                  setState(() {
                    _isDownloading = false;
                    thumbnail = data['thumbnail'];
                    downloadLink = data['url'];
                    type = data['type'];
                    if (downloadLink != "") {
                      downloadFile(context, downloadLink);
                    }
                    developer.log('thumbnail: $thumbnail \n downloadLink: $downloadLink \n type: $type');
                  });
                }
                showTopSnackBar(context, 'Downloading...', true);
              } else if (state is InstaDownloaderErrorState) {
                setState(() {
                  _isDownloading = false;
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
