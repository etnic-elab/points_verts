import 'package:flutter/material.dart';

const String applicationName = "ADEPS - Points Verts";
const String companyMail = "innovation@etnic.be";
const String githubUrl = "https://github.com/etnic-elab/points_verts";
const String opendataUrl =
    "https://www.odwb.be/explore/dataset/points-verts-de-ladeps";
const String _publicUrl = "https://adeps-points-verts.innovation-etnic.be";
const String assistanceUrl = "$_publicUrl/assistance.html";
const String privacyUrl = "$_publicUrl/privacy.html";
const String accessibilityUrl = "$_publicUrl/accessibilite.html";
const String publicLogo = "$_publicUrl/logo_50x50.png";
const String publicLogoCancelledLight =
    "$_publicUrl/logo_cancelled_light_50x50.png";
const String publicLogoCancelledDark =
    "$_publicUrl/logo_cancelled_dark_50x50.png";

class CompanyColors {
  static const greenPrimary = Color(0xFF6CB233);
  static const greenSecondary = Color(0xFF5B9434);
  static const lightGreen = Color(0xFF3FBA44);
  static const lightestGreen = Color(0xFF7ECC2F);
  static const darkGreen = Color(0xFF246739);
  static const darkestGreen = Color(0xFF466025);
  static const brown = Color(0xFFAD7158);
  static const darkBrown = Color(0xFF5D2D14);
  static const blue = Color(0xFF52ABE4);
  static const darkBlue = Color(0xFF5B97C3);
  static const black = Color(0xFF191718);
  static const pink = Color(0xFFED0D8E);
  static const yellow = Color(0xFFC3C83A);
  static const purple = Color(0xFF84547A);
  static const orange = Color(0xFFF3612B);
  static const red = Color(0xFFD7272E);
  static const lightRed = Color(0xFFF03B33);
  static const darkRed = Color(0xFF811620);

  static Color contextualRed(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? lightRed : red;
  }
}

class CompanyTheme {
  static final greenSecondaryMatCol =
      _createMaterialColor(CompanyColors.greenSecondary);

  static final ThemeData companyLight =
      ThemeData(colorSchemeSeed: greenSecondaryMatCol);

  static final ThemeData companyDark = ThemeData(
      brightness: Brightness.dark, colorSchemeSeed: greenSecondaryMatCol);

  static MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
