import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streamnexadmin/core/constants/color_constants.dart';

class TextStyles {
  static signupHeadding({double? size, FontWeight? weight, Color? color}) {
    return GoogleFonts.montserrat(color: ColorTheme.white, fontSize: 20);
  }

  static registarionTexts({double? size, FontWeight? weight, Color? color}) {
    return GoogleFonts.montserrat(color: ColorTheme.white, fontSize: 15);
  }

   static appBarHeadding({double? size, FontWeight? weight, Color? color}) {
    return GoogleFonts.montserrat(color: ColorTheme.secondaryColor, );
  }

  // Dashboard styles
  static subText({double? size, FontWeight? weight, Color? color}) {
    return GoogleFonts.montserrat(
      color: color ?? ColorTheme.white,
      fontSize: size ?? 20,
      fontWeight: weight ?? FontWeight.bold,
    );
  }
static smallText({double? size, FontWeight? weight, Color? color}) {
    return GoogleFonts.montserrat(
      color: color ?? ColorTheme.grey,
      fontSize: size ?? 15,
      fontWeight: weight ?? FontWeight.bold,
    );
  }
}