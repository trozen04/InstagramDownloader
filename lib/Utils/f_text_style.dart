import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'flutter_color_themes.dart';

class FTextStyle {
  static TextStyle heading(BuildContext context) => GoogleFonts.outfit(
    fontSize: MediaQuery.of(context).size.width * 0.05, // 24px on 400px width
    fontWeight: FontWeight.w500,
    color: AppColors.brandNew,
  );

  static TextStyle joinCompleteMatchTab(BuildContext context) => GoogleFonts.outfit(
    fontSize: MediaQuery.of(context).size.width * 0.032, // ~13px on 400px width
    fontWeight: FontWeight.w600,
    color: AppColors.login_registerr,
  );

  static TextStyle joinCompleteMatchTabUnselected(BuildContext context) => GoogleFonts.outfit(
    fontSize: MediaQuery.of(context).size.width * 0.032,
    fontWeight: FontWeight.w600,
    color: const Color(0xffFFFFFF).withOpacity(0.7),
  );

  static TextStyle subheading(BuildContext context) => GoogleFonts.outfit(
    fontSize: MediaQuery.of(context).size.width * 0.045, // 18px
    fontWeight: FontWeight.w500,
    color: AppColors.greyText,
  );

  static TextStyle body(BuildContext context) => GoogleFonts.outfit(
    fontSize: MediaQuery.of(context).size.width * 0.035, // 14px
    fontWeight: FontWeight.normal,
    color: AppColors.mobilenumber,
  );

  static TextStyle button(BuildContext context) => GoogleFonts.outfit(
    fontSize: MediaQuery.of(context).size.width * 0.04, // 16px
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static TextStyle outfitRegular({
    required BuildContext context,
    double? fontSize,
    Color? color,
  }) =>
      GoogleFonts.outfit(
        fontSize: fontSize ?? MediaQuery.of(context).size.width * 0.035,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.mobilenumber,
      );
}
