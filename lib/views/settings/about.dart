import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:points_verts/company_data.dart';
import 'package:points_verts/asset.dart';
import 'package:points_verts/views/walks/walk_utils.dart';

class About extends StatelessWidget {
  const About({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: PackageInfo.fromPlatform(),
        builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return ListTile(
                leading: const Icon(Icons.info),
                title: const Text("À propos"),
                onTap: () {
                  showAboutDialog(
                      context: context,
                      applicationIcon: Image(
                          image: Assets.assetImage(Assets.logo, context),
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
                        const _AboutRow("Données de navigation", "Mapbox",
                            "https://www.mapbox.com"),
                        const _AboutRow("Données météorologiques",
                            "OpenWeather", "https://openweathermap.org")
                      ]);
                });
          } else {
            return const SizedBox.shrink();
          }
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
