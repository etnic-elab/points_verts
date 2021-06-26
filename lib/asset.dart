import 'package:flutter/material.dart';

class Assets {
  static const String logo = 'logo';
  static const String logoAnnule = 'logo-annule';

  static AssetImage assetImage(String asset, BuildContext context) {
    String brightness =
        Theme.of(context).brightness == Brightness.dark ? 'dark' : 'light';
    return AssetImage('assets/$brightness/$asset.png');
  }
}
