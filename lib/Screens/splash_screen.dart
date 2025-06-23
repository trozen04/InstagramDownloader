import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram_downloader_project/Utils/f_text_style.dart';
import 'package:instagram_downloader_project/Utils/flutter_color_themes.dart';
import 'package:instagram_downloader_project/Utils/image_assets.dart';
import 'dart:developer' as developer;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    developer.log('SplashScreen initState called', name: 'SplashScreen');
    // Navigate immediately for testing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        developer.log('SplashScreen: Navigating to HomeScreen', name: 'SplashScreen');
        Future.delayed(Duration(seconds: 1),() {
          Navigator.pushReplacementNamed(context, '/home');
        });
      } else {
        developer.log('SplashScreen: Not mounted, navigation skipped', name: 'SplashScreen');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    developer.log('SplashScreen build called', name: 'SplashScreen');
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(ImageAssets.appIconHome, width: MediaQuery.of(context).size.width * 0.5),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Text(
              'VidLoader By Trozen',
              style: FTextStyle.heading(context).copyWith(color: AppColors.brandNew),
            ),
          ],
        ),
      ),
    );
  }
}