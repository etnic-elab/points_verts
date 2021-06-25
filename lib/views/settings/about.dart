import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:points_verts/company_data.dart';
import 'package:points_verts/views/walks/walk_utils.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                      applicationName: APPLICATION_NAME,
                      applicationVersion: snapshot.data!.version,
                      applicationLegalese: "GNU GPLv3",
                      children: [
                        _AboutRow("Dépôt du code source", "GitHub", GITHUB_URL),
                        _AboutRow("Adresse de contact", COMPANY_MAIL,
                            "mailto:$COMPANY_MAIL?subject=Points Verts"),
                        _AboutRow("Données des Points Verts",
                            "Open Data Wallonie-Bruxelles", OPENDATA_URL),
                        _AboutRow("Données de navigation", "Mapbox",
                            "https://www.mapbox.com"),
                        _AboutRow("Données météorologiques", "OpenWeather",
                            "https://openweathermap.org")
                      ]);
                });
          } else {
            return SizedBox.shrink();
          }
        });
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
      subtitle: Text(buttonLabel),
      onTap: () {
        launchURL(url);
      },
    );
  }
}
