import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:points_verts/views/walks/walk_utils.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String emailAddress = _getEmailAddress();
    return FutureBuilder(
        future: PackageInfo.fromPlatform(),
        builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return ListTile(
                leading: Icon(Icons.info),
                title: Text("À propos"),
                onTap: () {
                  showAboutDialog(
                      context: context,
                      applicationIcon: Image(
                          image: AssetImage('assets/logo.png'), height: 50),
                      applicationName: "Points Verts",
                      applicationVersion: snapshot.data.version,
                      applicationLegalese: "GNU GPLv3",
                      children: [
                        _AboutRow("Dépôt du code source", "GitHub",
                            "https://github.com/tborlee/points_verts"),
                        _AboutRow("Adresse de contact", emailAddress,
                            "mailto:$emailAddress?subject=Points Verts"),
                        _AboutRow(
                            "Données des Points Verts",
                            "Open Data Wallonie-Bruxelles",
                            "https://www.odwb.be/explore/dataset/points-verts-de-ladeps/"),
                        _AboutRow("Données de navigation", "Mapbox",
                            "https://www.mapbox.com/"),
                        _AboutRow("Données météorologiques", "OpenWeather",
                            "https://openweathermap.org/")
                      ]);
                });
          } else {
            return SizedBox.shrink();
          }
        });
  }

  String _getEmailAddress() {
    if (Platform.isIOS) {
      return "ios@alpagaga.dev";
    } else {
      return "android@alpagaga.dev";
    }
  }
}

class _AboutRow extends StatelessWidget {
  _AboutRow(this.label, this.buttonLabel, this.url);

  final String label;
  final String buttonLabel;
  final String url;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: buttonLabel != null ? Text(buttonLabel) : null,
      onTap: () {
        launchURL(url);
      },
    );
  }
}
