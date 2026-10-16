import 'package:flutter/material.dart';

const String applicationName = "Marches Adeps";
const String companyMail = "innovation@etnic.be";
const String githubUrl = "https://github.com/etnic-elab/points_verts";
const String opendataUrl =
    "https://www.odwb.be/explore/dataset/points-verts-de-ladeps";
const String _publicUrl = "https://adeps-points-verts.innovation-etnic.be";
const String assistanceUrl = "$_publicUrl/assistance.html";
const String privacyUrl = "$_publicUrl/privacy.html";
const String accessibilityUrl = "$_publicUrl/accessibilite.html";
// Walk markers for static map images: the map provider fetches them by URL,
// so they are hosted on the public site. Rendered by
// tool/build_brand_assets.dart (web/ in points_verts_assets) and uploaded by
// hand.
const String walkMarkerUrl = "$_publicUrl/walk_marker_32.png";
const String cancelledWalkMarkerUrlLight =
    "$_publicUrl/walk_marker_cancelled_light_32.png";
const String cancelledWalkMarkerUrlDark =
    "$_publicUrl/walk_marker_cancelled_dark_32.png";

class CompanyColors {
  static const greenPrimary = Color(0xFF6CB233);
  static const greenSecondary = Color(0xFF5B9434);
  static const orange = Color(0xFFE57710);
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
  static const red = Color(0xFFD7272E);
  static const lightRed = Color(0xFFF03B33);
  static const darkRed = Color(0xFF811620);

  /// The app icon's navy and orange.
  static const navy = Color(0xFF002F69);
  static const lightOrange = Color(0xFFED9E41);

  static Color contextualRed(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? lightRed : red;
  }

  /// Ring around a walk marker on the map: navy, like the marker itself, or
  /// orange to pick out the selected walk.
  static Color walkMarkerRing({required bool selected}) {
    return selected ? lightOrange : navy;
  }
}

class CompanyTheme {
  static final ThemeData companyLight = ThemeData(
    colorSchemeSeed: CompanyColors.orange,
  );

  static final ThemeData companyDark = ThemeData(
    brightness: Brightness.dark,
    colorSchemeSeed: CompanyColors.orange,
  );
}
