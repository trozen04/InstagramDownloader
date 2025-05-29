import 'package:flutter/material.dart';
import 'package:instagram_downloader_project/Utils/f_text_style.dart';
import 'package:instagram_downloader_project/Utils/flutter_color_themes.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  const CustomTextField({super.key, required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textfieldborder),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: FTextStyle.body(context).copyWith(color: AppColors.hintText),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.04,
            vertical: MediaQuery.of(context).size.height * 0.02,
          ),
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const CustomButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          //gradient: AppColors.sequenceBG,

          color: AppColors.brandNewBg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: AppColors.containerShadow,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.02,
          horizontal: MediaQuery.of(context).size.width * 0.08,
        ),
        child: Center(
          child: Text(
            text,
            style: FTextStyle.button(context),
          ),
        ),
      ),
    );
  }
}

class MediaCard extends StatelessWidget {
  final String title;
  final String subtitle;
  const MediaCard({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
      padding: EdgeInsets.symmetric(vertical: height * 0.01, horizontal: width * 0.04),
      decoration: BoxDecoration(
        color: AppColors.containerBG,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.containerBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: FTextStyle.subheading(context)),
          SizedBox(height: MediaQuery.of(context).size.height * 0.005),
          Text(subtitle, style: FTextStyle.body(context).copyWith(color: AppColors.greyText)),
        ],
      ),
    );
  }
}

void showTopSnackBar(BuildContext context, String message, bool isSuccess) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSuccess ? AppColors.brandNew : AppColors.failed,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}