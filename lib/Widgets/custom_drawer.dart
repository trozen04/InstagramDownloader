import 'package:flutter/material.dart';
import 'package:instagram_downloader_project/Utils/f_text_style.dart';
import 'package:instagram_downloader_project/Utils/flutter_color_themes.dart';
import 'package:instagram_downloader_project/Utils/image_assets.dart';

import 'common_widgets.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white, // Soft Gray background
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.white),
            child: Image.asset(ImageAssets.appIconHome)
          ),
          CustomListTile(
            icon: Icons.maps_home_work_rounded,
            title: 'Home',
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            },
          ),
          CustomListTile(
            icon: Icons.info_rounded,
            title: 'About',
            onTap: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
          CustomListTile(
            icon: Icons.contact_mail,
            title: 'Contact Me',
            onTap: () {
              Navigator.pushNamed(context, '/contact');
            },
          ),
        ],
      ),
    );
  }
}

