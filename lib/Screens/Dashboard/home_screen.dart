import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:instagram_downloader_project/Utils/constants.dart';
import 'package:instagram_downloader_project/Utils/f_text_style.dart';
import 'package:instagram_downloader_project/Utils/flutter_color_themes.dart';
import 'package:instagram_downloader_project/Utils/image_assets.dart';
import 'package:instagram_downloader_project/Widgets/Advertisement/BannerAdWidget.dart';
import 'package:instagram_downloader_project/Widgets/common_widgets.dart';
import 'package:instagram_downloader_project/Utils/shared_prefs.dart';
import 'package:instagram_downloader_project/Widgets/custom_drawer.dart';
import 'package:instagram_downloader_project/Widgets/download_function.dart';
import 'package:instagram_downloader_project/Widgets/text_animation.dart';
import 'package:instagram_downloader_project/main.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin, RouteAware {
  final TextEditingController controller = TextEditingController();
  List<Map<String, String>> recentDownloads = [];
  final SharedPrefs _sharedPrefs = SharedPrefs();
  late TabController _tabController;
  final List<String> _platforms = ['Instagram', 'YouTube', 'Facebook', 'LinkedIn'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _platforms.length, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild on tab change
    });
    _loadRecentDownloads();
  }

  Future<void> _openFile(String? filePath) async {
    developer.log('path: $filePath');
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


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    _loadRecentDownloads();
  }

  Future<void> _loadRecentDownloads() async {
    final history = await _sharedPrefs.getHistory();
    setState(() {
      recentDownloads = history.take(10).toList(); // reverse + take last 10
    });
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _tabController.removeListener(() {});
    _tabController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    String selectedPlatform = _platforms[_tabController.index];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('VidLoader', style: FTextStyle.heading(context)),
        backgroundColor: AppColors.my_profile_bg_color,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Image.asset(ImageAssets.appIconHome),
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
        decoration: BoxDecoration(

          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18)
          )
        ),
        height: double.infinity,
        child: Column(
          children: [
            // 🔁 Scrollable part only
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide.none,
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: false,
                        labelPadding: EdgeInsets.zero,
                        splashFactory: NoSplash.splashFactory,
                        overlayColor: MaterialStateProperty.all(Colors.transparent),
                        indicator: BoxDecoration(), // ✅ removes indicator
                        tabs: _platforms.asMap().entries.map((entry) {
                          int index = entry.key;
                          String platform = entry.value;
                          bool isSelected = _tabController.index == index;
                          return Container(
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.brandNew : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),

                            ),
                            padding: EdgeInsets.symmetric(horizontal: width * 0.01, vertical: height * 0.01),
                            child: Center(
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
                    AnimatedTextWidget(
                      text: 'Paste $selectedPlatform URL',
                      style: FTextStyle.subheading(context),
                      key: ValueKey(selectedPlatform),
                    ),
                    SizedBox(height: height * 0.03),
                    CustomTextField(
                      controller: controller,
                      hintText: 'Enter $selectedPlatform URL here',
                    ),
                    SizedBox(height: height * 0.03),
                    Center(
                      child: CustomButton(
                        text: 'Download',
                        onPressed:
                              () {
                            if (controller.text.isNotEmpty) {
                              developer.log(
                                  'url: ${controller.text}\ntype: ${selectedPlatform.toLowerCase()}');
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
                        }
                      ),
                    ),
                    SizedBox(height: height * 0.03),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Downloads', style: FTextStyle.subheading(context)),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/history'),
                            child: Text('View all', style: FTextStyle.body(context))
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.01),
                    recentDownloads.isEmpty
                        ? Center(
                      child: Text(
                        'No recent downloads',
                        style: FTextStyle.body(context).copyWith(color: AppColors.greyText),
                      ),
                    )
                        : ListView.builder(
                      itemCount: recentDownloads.length,
                      shrinkWrap: true, // important when inside scroll view
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final item = recentDownloads[index];
                        return GestureDetector(
                          onTap: () {
                            _openFile(item['filePath']);
                          },
                          child: MediaCard(
                            title: item['title']!,
                            subtitle: item['timestamp']!,
                            thumbnail: item['thumbnail']!,
                          ),
                        );

                      },
                    ),
                  ],
                ),
              ),
            ),

            // 📢 Fixed Banner Ad
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