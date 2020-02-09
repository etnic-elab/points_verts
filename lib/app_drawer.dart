import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:points_verts/settings.dart';
import 'package:points_verts/walk_list.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
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
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => WalkList()));
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Paramètres'),
            onTap: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => Settings()));
            },
          ),
          Divider(),
          ListTile(
            title: FutureBuilder(
                future: PackageInfo.fromPlatform(),
                builder: (BuildContext context,
                    AsyncSnapshot<PackageInfo> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      PackageInfo info = snapshot.data;
                      return Text("${info.version}+${info.buildNumber}");
                    }
                  }
                  return SizedBox();
                }),
          ),
        ],
      ),
    );
  }
}
