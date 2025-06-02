import 'package:flutter/material.dart';
import 'package:instagram_downloader_project/Utils/f_text_style.dart';
import 'package:instagram_downloader_project/Utils/flutter_color_themes.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.brandNew,
        title: Text(
          'About',
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
                    'About VidDownloader',
                    style: FTextStyle.subheading(context),
                  ),
                  SizedBox(height: height * 0.01),
                  Text(
                    'VidDownloader is a media downloading app that lets you save videos from platforms like Instagram, YouTube, and more. '
                        'Built with passion by Trozen (Software Developer), this app offers an intuitive UI '
                        'and robust features to manage your downloads seamlessly.',
                    style: FTextStyle.body(context),
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(height: height * 0.03),
                  CustomInfoRow(
                    context: context,
                    title: 'Version: ',
                    value: '1.0.4',
                  ),
                  SizedBox(height: height * 0.01),
                  CustomInfoRow(
                    context: context,
                    title: 'Developed by: ',
                    value: 'Trozen',
                  ),
                  SizedBox(height: height * 0.01),
                  CustomInfoRow(
                    context: context,
                    title: '© 2025 ',
                    value: '[Trozen]',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget CustomInfoRow({
    required BuildContext context,
    required String title,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: FTextStyle.body(context),
        ),
        Text(
          value,
          style: FTextStyle.body(context).copyWith(color: AppColors.greyText),
        ),
      ],
    );
  }
}