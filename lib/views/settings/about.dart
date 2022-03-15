import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:points_verts/company_data.dart';
import 'package:points_verts/environment.dart';
import 'package:points_verts/services/assets.dart';
import 'package:points_verts/views/tile_icon.dart';
import 'package:points_verts/views/walks/walk_utils.dart';

class About extends StatelessWidget {
  const About({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: PackageInfo.fromPlatform(),
        builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
          if (snapshot.hasData) {
            return ListTile(
                leading: const TileIcon(Icon(Icons.info)),
                title: const Text("À propos"),
                onTap: () {
                  showAboutDialog(
                      context: context,
                      applicationIcon: Image(
                          image: Assets.asset
                              .image(Theme.of(context).brightness, Assets.logo),
                          height: 50),
                      applicationName: applicationName,
                      applicationVersion: snapshot.data!.version,
                      applicationLegalese: "GNU GPLv3",
                      children: [
                        const _AboutRow(
                            "Dépôt du code source", "GitHub", githubUrl),
                        const _AboutRow("Adresse de contact", companyMail,
                            "mailto:$companyMail?subject=Points Verts"),
                        const _AboutRow("Données des Points Verts",
                            "Open Data Wallonie-Bruxelles", opendataUrl),
                        _AboutRow("Données de navigation", Environment.mapApi,
                            Environment.mapWebsite),
                        const _AboutRow("Données météorologiques",
                            "OpenWeather", "https://openweathermap.org")
                      ]);
                });
          }
          return const SizedBox.shrink();
        });
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow(this.label, this.buttonLabel, this.url);

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
