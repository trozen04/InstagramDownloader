import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:instagram_downloader_project/Screens/APIBloc/insta_downloader_bloc.dart';
import 'package:instagram_downloader_project/Utils/constants.dart';
import 'package:instagram_downloader_project/Utils/f_text_style.dart';
import 'package:instagram_downloader_project/Utils/file_utils.dart';
import 'package:instagram_downloader_project/Utils/flutter_color_themes.dart';
import 'package:instagram_downloader_project/Widgets/Advertisement/BannerAdWidget.dart';
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
  List<Map<String, String>> recentDownloads = [];
  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadRecentDownloads() async {
    final history = await _sharedPrefs.getHistory();
    setState(() {
      recentDownloads = history.take(1).toList(); // reverse + take last 10
    });
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
      thumbnail: thumbnail
    );
    if (downloadSuccess) {
      setState(() {
        _isDownloading = false;
        _status = 'Download Complete!';
        _progress = 1.0;
      });
      _loadRecentDownloads();
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
        title: Text('Downloading Your Video', style: FTextStyle.heading(context).copyWith(color: Colors.white)),
        backgroundColor: AppColors.brandNew,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
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

                if (widget.type == 'youtube') {
                  // Handle YouTube case (single object)
                  if (resultData is Map<String, dynamic> && resultData.containsKey('url')) {
                    downloadLink = resultData['url'];
                    await _simulateDownload(downloadLink); // Start actual download

                  } else {
                    setState(() {
                      _isDownloading = false;
                      _status = 'No valid download link found.';
                    });
                    showTopSnackBar(context, 'No valid download link found.', false);
                  }
                } else {
                  // Handle other platforms (list-based response)
                  if (resultData.isNotEmpty && resultData[0] is Map) {
                    final data = resultData[0];

                    setState(() {
                      thumbnail = data?['thumbnail'];
                      downloadLink = data?['url'];
                      type = data.containsKey('type') ? data['type'] : 'Video';
                    });
                    showTopSnackBar(context, 'Starting Download...', true);

                    if (downloadLink != "") {
                      await _simulateDownload(downloadLink); // Start actual download
                    }

                  }
                }
              } else if (state is InstaDownloaderErrorState) {

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
                SizedBox(height: height * 0.01),
                SizedBox(height: height * 0.01,),
                ListView.builder(
                  itemCount: recentDownloads.length,
                  shrinkWrap: true, // important when inside scroll view
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = recentDownloads[index];
                    return GestureDetector(
                      onTap: () {
                        openFile(
                          context,
                          item['filePath'],
                          showTopSnackBar: showTopSnackBar,
                          openManageAllFilesPermission: openManageAllFilesPermission,
                        );
                      },
                      child: MediaCard(
                        title: item['title']!,
                        subtitle: item['timestamp']!,
                        thumbnail: item['thumbnail']!,
                      ),
                    );

                  },
                ),
                SizedBox(height: height * 0.01),
                if(recentDownloads.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Thank you for using VidLoader', style: FTextStyle.body(context)),
                    Column(
                      children: [
                        SizedBox(height: height * 0.02),
                        Text('~Trozen', style: FTextStyle.body(context)),
                      ],
                    ),
                  ],
                ),
                Spacer(),
                Text('Version: 1.0.4', style: FTextStyle.body(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}