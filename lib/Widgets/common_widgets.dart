import 'package:flutter/material.dart';
import 'package:instagram_downloader_project/Utils/f_text_style.dart';
import 'package:instagram_downloader_project/Utils/flutter_color_themes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'CUstomSNackbar.dart';

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
          boxShadow: AppColors.customShadow
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
  final String? thumbnail;

  const MediaCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.thumbnail,
  });


  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: height * 0.005,
        horizontal: width * 0.0,
      ),
      padding: EdgeInsets.all(height * 0.015),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textBorder.withOpacity(0.3)
        ),
       boxShadow: AppColors.customShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildThumbnail(context, width),
          ),
          SizedBox(width: width * 0.03), // Spacing between image and text
          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FTextStyle.subheading(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: height * 0.005),
                Text(
                  formatDate(subtitle),
                  style: FTextStyle.body(context).copyWith(
                    color: AppColors.greyText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context, double width) {
    // Check if thumbnail URL is null, empty, or invalid
    if (thumbnail == null || thumbnail!.isEmpty || !Uri.parse(thumbnail!).isAbsolute) {
      return Container(
        width: width * 0.2,
        height: width * 0.2,
        color: AppColors.previewBG,
        child: const Icon(
          Icons.videocam,
          size: 30,
          color: AppColors.preview,
        ),
      );
    }

    return SizedBox(
      width: width * 0.2,
      height: width * 0.2,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: thumbnail ?? '',
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}

OverlayEntry? _currentOverlayEntry;

void showTopSnackBar(BuildContext context, String message, bool isSuccess) {
  _currentOverlayEntry?.remove(); // Remove existing snackbar if any

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
            boxShadow: AppColors.customShadow
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

  _currentOverlayEntry = overlayEntry;
  overlay.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 3), () {
    overlayEntry.remove();
    if (_currentOverlayEntry == overlayEntry) {
      _currentOverlayEntry = null;
    }
  });
}

String formatDate(String timestamp) {
  try {
    DateTime date = DateTime.parse(timestamp);
    return DateFormat("ddMMM, yyyy").format(date); // e.g., 30Apr,2025
  } catch (e) {
    return timestamp;
  }
}

Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false, // forces the user to choose
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.brandNew, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Delete All History?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'This will remove all downloaded files and history permanently. Are you sure you want to proceed?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.brandNew,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Cancel', style: FTextStyle.body(context).copyWith(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Delete', style: FTextStyle.body(context).copyWith(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  ) ?? false;
}


class CustomListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const CustomListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.brandNew, size: 20),
          title: Text(title, style: FTextStyle.body(context)),
          onTap: onTap,
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: AppColors.textfieldborder, // Or use a theme color if preferred
        ),
      ],
    );
  }
}

void openURL(BuildContext context, String urlString) async {
  if (urlString.isEmpty || urlString.trim().isEmpty) {
    CustomSnackbar.show(context, message: 'URL is empty', isSuccess: false);
    return;
  }

  String cleanedUrl = urlString.trim();
  if (!cleanedUrl.startsWith('http://') && !cleanedUrl.startsWith('https://')) {
    cleanedUrl = 'https://$cleanedUrl';
  }

  try {
    final Uri url = Uri.parse(cleanedUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.platformDefault);
    } else {
      CustomSnackbar.show(context, message: 'Could not launch URL', isSuccess: false);
    }
  } catch (e) {
    CustomSnackbar.show(context, message: 'Invalid URL: $e', isSuccess: false);
  }
}
