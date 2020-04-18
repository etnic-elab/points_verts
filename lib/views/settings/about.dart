import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.info),
        onPressed: () {
          showAboutDialog(
              context: context,
              applicationIcon:
                  Image(image: AssetImage('assets/logo.png'), height: 50),
              applicationName: "Points Verts",
              applicationVersion: "1.0",
              applicationLegalese: "GNU GPLv3",
              children: [
                _AboutRow("Code source", "Disponible sur GitHub",
                    "https://github.com/tborlee/points_verts"),
                _AboutRow("Adresse de contact", "android@alpagaga.dev",
                    "mailto:android@alpagaga.dev?subject=Points Verts"),
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
  }
}

class _AboutRow extends StatelessWidget {
  _AboutRow(this.label, this.buttonLabel, this.url);

  final String label;
  final String buttonLabel;
  final String url;

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(label),
      subtitle: buttonLabel != null ? Text(buttonLabel) : null,
      onTap: () {
        _launchURL(url);
      },
    );
  }
}
