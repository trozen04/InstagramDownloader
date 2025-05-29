import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:instagram_downloader_project/Screens/APIBloc/insta_downloader_bloc.dart';
import 'package:instagram_downloader_project/Utils/f_text_style.dart';
import 'package:instagram_downloader_project/Utils/flutter_color_themes.dart';
import 'package:instagram_downloader_project/Widgets/common_widgets.dart';
import 'package:instagram_downloader_project/Utils/shared_prefs.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram_downloader_project/Widgets/text_animation.dart';


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
  final List<String> _platformKeys = ['instagram', 'youtube', 'facebook', 'linkedin'];

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
    setState(() {
      recentDownloads = history.reversed.take(2).toList();
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
      appBar: AppBar(
        title: Text('Downloader', style: FTextStyle.heading(context)),
        backgroundColor: AppColors.my_profile_bg_color,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
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
                    color: isSelected ? AppColors.buttoncolor : Colors.transparent,
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
            padding: EdgeInsets.symmetric(vertical: height * 0.01, horizontal: width * 0.04),
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
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        Navigator.pushNamed(
                          context,
                          '/download',
                          arguments: controller.text,
                        );
                        controller.clear();
                      } else {
                        showTopSnackBar(context, 'Please enter a URL.', false);
                      }
                    },
                  ),
                ),
                SizedBox(height: height * 0.03),
                Text('Recent Downloads', style: FTextStyle.subheading(context)),
                Expanded(
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
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
