import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:points_verts/company_data.dart';
import 'package:points_verts/constants.dart';
import 'package:points_verts/services/assets.dart';
import 'package:points_verts/views/tile_icon.dart';
import 'package:points_verts/views/walks/walk_utils.dart';
import 'package:points_verts/services/map/map_interface.dart';

class About extends StatelessWidget {
  const About({super.key});

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
                          "Dépôt du code source",
                          "GitHub",
                          githubUrl,
                          Icon(Icons.open_in_browser,
                              semanticLabel: "Ouvrir dans le navigateur"),
                        ),
                        const _AboutRow(
                          "Adresse de contact",
                          companyMail,
                          "mailto:$companyMail?subject=Points Verts",
                          Icon(Icons.email, semanticLabel: "Envoyer un mail"),
                        ),
                        const _AboutRow(
                          "Données des Points Verts",
                          "Open Data Wallonie-Bruxelles",
                          opendataUrl,
                          Icon(Icons.open_in_browser,
                              semanticLabel: "Ouvrir dans le navigateur"),
                        ),
                        _AboutRow(
                            "Données de navigation",
                            kMap.instance.name,
                            kMap.instance.website,
                            const Icon(
                              Icons.open_in_browser,
                              semanticLabel: "Ouvrir dans un navigateur",
                            )),
                        const _AboutRow(
                            "Données météorologiques",
                            "OpenWeather",
                            "https://openweathermap.org",
                            Icon(Icons.open_in_browser,
                                semanticLabel: "Ouvrir dans le navigateur")),
                      ]);
                });
          }
          return const SizedBox.shrink();
        });
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow(this.label, this.buttonLabel, this.url, this.icon);

  final String label;
  final String buttonLabel;
  final String url;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text(buttonLabel),
      trailing: icon,
      onTap: () {
        launchURL(url);
      },
    );
  }
}
