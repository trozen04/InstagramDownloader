import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:instagram_downloader_project/Screens/APIBloc/insta_downloader_bloc.dart';
import 'package:instagram_downloader_project/Utils/f_text_style.dart';
import 'package:instagram_downloader_project/Utils/flutter_color_themes.dart';
import 'package:instagram_downloader_project/Utils/image_assets.dart';
import 'package:instagram_downloader_project/Widgets/common_widgets.dart';
import 'package:instagram_downloader_project/Utils/shared_prefs.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram_downloader_project/Widgets/text_animation.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' hide RefreshIndicator;


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
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

  Future<void> _loadRecentDownloads() async {
    final history = await _sharedPrefs.getHistory();
    developer.log('history: ${history}');
    setState(() {
      recentDownloads = history.reversed.take(10).toList();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(() {}); // Clean up listener
    _tabController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('VidDownloader', style: FTextStyle.heading(context)),
        backgroundColor: AppColors.my_profile_bg_color,
        leading: Image.asset(ImageAssets.appIconHome, height: 20, width: 20,),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_toggle_off_rounded),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
          SizedBox(width: width * 0.04),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: SizedBox(
            height: kToolbarHeight,
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              labelPadding: EdgeInsets.zero,
              splashFactory: NoSplash.splashFactory,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              indicatorColor: Colors.transparent, // Remove default indicator
              tabs: _platforms.asMap().entries.map((entry) {
                int index = entry.key;
                String platform = entry.value;
                bool isSelected = _tabController.index == index;
                return Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.brandNew : Colors.transparent,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
        ),

      ),
      body: TabBarView(
        controller: _tabController,
        children: _platforms.asMap().entries.map((entry) {
          int index = entry.key;
          String platform = entry.value;
          return Padding(
            padding: EdgeInsets.symmetric(vertical: height * 0.01, horizontal: width * 0.035),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedTextWidget(
                  text: 'Paste $platform URL',
                  style: FTextStyle.subheading(context),
                  key: ValueKey(platform),
                ),
                SizedBox(height: height * 0.02),
                CustomTextField(
                  controller: controller,
                  hintText: 'Enter $platform URL here',
                ),
                SizedBox(height: height * 0.03),
                Center(
                  child: CustomButton(
                    text: 'Download',
                    onPressed: platform != 'YouTube' ? () {
                      if (controller.text.isNotEmpty) {
                        developer.log('url: ${controller.text}\ntype: ${platform.toLowerCase()}');
                        Navigator.pushNamed(
                          context,
                          '/download',
                          arguments: {
                            'url': controller.text,
                            'type': platform.toLowerCase(),
                          },
                        );
                        controller.clear();
                      } else {
                        showTopSnackBar(context, 'Please enter a URL.', false);
                      }
                    } : () {
                      showTopSnackBar(context, 'This feature is not available right now.', false);
                    },

                  ),
                ),
                SizedBox(height: height * 0.03),
                Text('Recent Downloads', style: FTextStyle.subheading(context)),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadRecentDownloads,
                    child: recentDownloads.isEmpty
                      ? Center(
                    child: Text(
                      'No recent downloads',
                      style: FTextStyle.body(context).copyWith(color: AppColors.greyText),
                    ),
                  )
                      : ListView.builder(
                    itemCount: recentDownloads.length,
                    itemBuilder: (context, index) {
                      final item = recentDownloads[index];
                      return MediaCard(
                        title: item['title']!,
                        subtitle: item['timestamp']!,
                        thumbnail: item['thumbnail']!,
                      );
                    },
                  ),
                ),
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
