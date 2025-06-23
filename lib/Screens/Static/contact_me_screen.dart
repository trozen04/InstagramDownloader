import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:instagram_downloader_project/Utils/f_text_style.dart';
import 'package:instagram_downloader_project/Utils/flutter_color_themes.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Widgets/CUstomSNackbar.dart';
import '../../Widgets/common_widgets.dart';

class ContactMeScreen extends StatefulWidget {
  const ContactMeScreen({super.key});

  @override
  _ContactMeScreenState createState() => _ContactMeScreenState();
}

class _ContactMeScreenState extends State<ContactMeScreen> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize AnimationController
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Define fade animation (opacity from 0 to 1)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Define slide animation (from 20 pixels below to original position)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2), // Slide from 20% below
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        CustomSnackbar.show(context, message: 'Could not launch $url. No email app found.', isSuccess: false);
      }
    } catch (e) {
      CustomSnackbar.show(context, message: 'Failed to launch $url', isSuccess: false);

    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white, // Soft Gray background
      appBar: AppBar(
        backgroundColor: AppColors.brandNew,
        title: Text(
          'Contact Me',
          style: FTextStyle.heading(context).copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: height * 0.01, horizontal: width * 0.035),
        child: SingleChildScrollView(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get in Touch',
                      style: FTextStyle.subheading(context)
                  ),
                  SizedBox(height: height * 0.01),
                  Text(
                    'Have questions or feedback? Reach out to us through the following channels:',
                      style: FTextStyle.body(context),
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(height: height * 0.03),
                  _buildContactTile(
                    icon: Icons.email,
                    title: 'Email',
                    subtitle: 'bhoopendrablog@gmail.com',
                    onTap: () => _launchURL(context, 'mailto:bhoopendrablog@gmail.com'),
                  ),
                  _buildContactTile(
                    icon: Icons.language,
                    title: 'Website',
                    subtitle: 'https://movieloadtime.blogspot.com/',
                    onTap: () => openURL(context,'https://trozenwho.blogspot.com/'),
                  ),
                  _buildContactTile(
                    icon: Icons.phone,
                    title: 'Phone',
                    subtitle: '+91-8887692942',
                    onTap: () => _launchURL(context, 'tel:+918887692942'),
                  ),
                  _buildContactTile(
                    icon: Icons.video_library, // or use a YouTube-specific icon if available
                    title: 'YouTube',
                    subtitle: '@trozen04',
                    onTap: () => _launchURL(context, 'https://www.youtube.com/@trozen04'),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.brandNew),
      title: Text(title, style: FTextStyle.body(context)),
      subtitle: Text(subtitle),
      onTap: onTap,
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}