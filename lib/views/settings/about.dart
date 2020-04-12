import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:points_verts/views/tile_icon.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: TileIcon(Icon(Icons.info)),
        title: Text("À propos de cette application"),
        onTap: () {
          showAboutDialog(
              context: context,
              applicationIcon:
                  Image(image: AssetImage('assets/logo.png'), height: 50),
              applicationName: "Points Verts",
              applicationVersion: "1.0",
              applicationLegalese: "GNU GPLv3",
              children: [
                RaisedButton.icon(
                    onPressed: () {
                      _launchURL(
                          "https://gitlab.com/thomas.borlee/points_verts");
                    },
                    icon: Icon(Icons.code),
                    label: Text("Code source")),
                RaisedButton.icon(
                    onPressed: () {
                      _launchURL("mailto:android@alpagaga.dev?subject=Points Verts");
                    },
                    icon: Icon(Icons.email),
                    label: Text("Contact")),
                RaisedButton.icon(
                    onPressed: () {
                      _launchURL("http://www.sport-adeps.be/index.php?id=5945");
                    },
                    icon: Icon(Icons.directions_walk),
                    label: Text("Portail Adeps")),
                RaisedButton.icon(
                    onPressed: () {
                      _launchURL(
                          "https://www.odwb.be/explore/dataset/points-verts-de-ladeps/");
                    },
                    icon: Icon(Icons.web),
                    label: Text("ODWB API"))
              ]);
        });
  }
}
