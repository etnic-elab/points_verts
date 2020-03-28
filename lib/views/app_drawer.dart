import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
                        child: Text("Points Verts Adeps",
                            style: Theme.of(context).primaryTextTheme.title)),
                  ])),
              ListTile(
                leading: Icon(Icons.directions_walk),
                title: Text('Prochains Points Verts'),
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => WalksView()));
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Paramètres'),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Scaffold(
                              appBar: AppBar(title: Text("Paramètres")),
                              drawer: AppDrawer(),
                              body: Settings())));
                },
              ),
            ],
          ),
        ),
      ],
    ));
  }
}
