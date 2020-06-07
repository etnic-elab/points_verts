import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:points_verts/views/directory/walk_directory_view.dart';

import 'settings/settings.dart';
import 'walks/walks_view.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  decoration:
                      BoxDecoration(color: Theme.of(context).primaryColor),
                  child: Stack(children: <Widget>[
                    Positioned(
                        bottom: 12.0,
                        left: 16.0,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.directions_walk),
                            Text(" Points Verts Adeps",
                                style:
                                    Theme.of(context).primaryTextTheme.headline6),
                          ],
                        )),
                  ])),
              ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text('Calendrier'),
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => WalksView()));
                },
              ),
              ListTile(
                leading: Icon(Icons.view_list),
                title: Text('Annuaire'),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WalkDirectoryView()));
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Paramètres'),
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Settings()));
                },
              ),
            ],
          ),
        ),
      ],
    ));
  }
}
