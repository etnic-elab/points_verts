import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../models/walk.dart';
import 'geo_button.dart';
import 'walk_details_view.dart';

bool smallScreen = window.physicalSize.width <= 640;

class WalkTile extends StatelessWidget {
  WalkTile(this.walk);

  final Walk walk;

  Widget build(BuildContext context) {
    return Card(
        margin: new EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: ListTile(
          title: Text(walk.city, style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text("${walk.type} - ${walk.province}"),
          onTap: () => Navigator.push(context, _pageRoute()),
          trailing: GeoButton(walk),
        ));
  }

  PageRoute _pageRoute() {
    return MaterialPageRoute(builder: (context) => WalkDetailsView(walk));
  }
}
