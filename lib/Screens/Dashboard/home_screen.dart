import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:instagram_downloader_project/Utils/constants.dart';
import 'package:instagram_downloader_project/Utils/f_text_style.dart';
import 'package:instagram_downloader_project/Utils/file_utils.dart';
import 'package:instagram_downloader_project/Utils/flutter_color_themes.dart';
import 'package:instagram_downloader_project/Widgets/common_widgets.dart';
import 'package:instagram_downloader_project/Utils/shared_prefs.dart';
import 'package:instagram_downloader_project/Widgets/custom_drawer.dart';
import 'package:instagram_downloader_project/Widgets/download_function.dart';
import '../../main.dart';

class HomeScreen extends StatefulWidget {
  final String? sharedText;
  const HomeScreen({super.key, this.sharedText});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin, RouteAware {
  final TextEditingController controller = TextEditingController();
  final SharedPrefs _sharedPrefs = SharedPrefs();
  final List<String> _platforms = ['Instagram', 'YouTube', 'Facebook', 'LinkedIn', 'Snapchat', 'Pinterest'];
  int _currentTabIndex = 0;
  Future<List<Map<String, String>>>? _recentDownloadsFuture;

  @override
  void initState() {
    super.initState();
    _recentDownloadsFuture = _loadRecentDownloads();
    if (widget.sharedText != null && widget.sharedText!.isNotEmpty) {
      
      controller.text = widget.sharedText!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          int targetIndex = 0;
          if (widget.sharedText!.contains('instagram.com')) {
            targetIndex = 0;
          } else if (widget.sharedText!.contains('youtube.com')) {
            targetIndex = 1;
          } else if (widget.sharedText!.contains('facebook.com')) {
            targetIndex = 2;
          } else if (widget.sharedText!.contains('linkedin.com')) {
            targetIndex = 3;
            
          } else if (widget.sharedText!.contains('snapchat.com')) {
            targetIndex = 4;
            
          } else if (widget.sharedText!.contains('pinterest.com')) {
            targetIndex = 5;
            
          }
          _currentTabIndex = targetIndex;
          
        });
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    
  }

  @override
  void didPopNext() {
    
  }

  Future<List<Map<String, String>>> _loadRecentDownloads() async {
    try {
      final history = await _sharedPrefs.getHistory();
      
      return history.take(10).toList();
    } catch (e) {
      
      return [];
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    String selectedPlatform = _platforms[_currentTabIndex];

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {}); // Force rebuild on tap
      },
      child: Column(
        children: [
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                title: Text('VidLoader', style: FTextStyle.heading(context)),
                backgroundColor: AppColors.my_profile_bg_color,
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.view_list_rounded, color: AppColors.brandNew),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.history_toggle_off_rounded, color: AppColors.brandNew),
                    onPressed: () => Navigator.pushNamed(context, '/history'),
                  ),
                  SizedBox(width: width * 0.04),
                ],
              ),
              drawer: const CustomDrawer(),
              body: Container(
                padding: EdgeInsets.symmetric(vertical: height * 0.01, horizontal: width * 0.035),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                height: double.infinity,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: _platforms.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  String platform = entry.value;
                                  bool isSelected = _currentTabIndex == index;

                                  return GestureDetector(
                                    onTap: () {
                                      if (_currentTabIndex != index) {
                                        setState(() {
                                          _currentTabIndex = index;
                                          controller.clear();

                                        });
                                      }
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(horizontal: width * 0.02),
                                      padding: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: height * 0.01),
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppColors.brandNew : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        platform,
                                        style: isSelected
                                            ? FTextStyle.body(context).copyWith(color: Colors.white)
                                            : FTextStyle.body(context).copyWith(color: AppColors.greyText),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            SizedBox(height: height * 0.02),
                            Text(
                              'Paste $selectedPlatform URL',
                              style: FTextStyle.subheading(context),
                              key: ValueKey(selectedPlatform),
                            ),
                            SizedBox(height: height * 0.03),
                            CustomTextField(
                              controller: controller,
                              hintText: 'Enter $selectedPlatform URL here',
                            ),
                            SizedBox(height: height * 0.01),
                            // if (selectedPlatform == 'Instagram')
                            //   Text(
                            //     'Please ensure user\'s account is public.',
                            //     style: FTextStyle.body(context).copyWith(color: AppColors.loss),
                            //   ),
                            SizedBox(height: height * 0.02),
                            Center(
                              child: CustomButton(
                                text: 'Download',
                                onPressed: () {
                                  if (controller.text.isNotEmpty) {

                                    Navigator.pushNamed(
                                      context,
                                      '/download',
                                      arguments: {
                                        'url': controller.text,
                                        'type': selectedPlatform.toLowerCase(),
                                      },
                                    );
                                    controller.clear();
                                  } else {
                                    showTopSnackBar(context, 'Please enter a URL.', false);
                                  }
                                },
                              ),
                            ),
                            SizedBox(height: height * 0.03),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Recent Downloads', style: FTextStyle.subheading(context)),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(context, '/history'),
                                  child: Text('View all', style: FTextStyle.body(context)),
                                ),
                              ],
                            ),
                            SizedBox(height: height * 0.01),
                            FutureBuilder<List<Map<String, String>>>(
                              future: _recentDownloadsFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {

                                  return const Center(child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {

                                  return Center(
                                    child: Text(
                                      'Error loading downloads',
                                      style: FTextStyle.body(context).copyWith(color: AppColors.greyText),
                                    ),
                                  );
                                }
                                final recentDownloads = snapshot.data ?? [];
                                if (recentDownloads.isEmpty) {
                                  return Center(
                                    child: Text(
                                      'No recent downloads',
                                      style: FTextStyle.body(context).copyWith(color: AppColors.greyText),
                                    ),
                                  );
                                }
                                return ListView.builder(
                                  itemCount: recentDownloads.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final item = recentDownloads[index];
                                    final thumbnail = item['thumbnail'] ?? 'assets/placeholder.png';
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
                                        thumbnail: thumbnail,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}