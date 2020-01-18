import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'geo_button.dart';
import 'walk.dart';
import 'walk_details_view.dart';
import 'walk_utils.dart';

class WalkTile extends StatelessWidget {
  WalkTile({this.walk});

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    bool smallScreen = window.physicalSize.width <= 640;
    return ListTile(
      dense: smallScreen,
      leading: smallScreen
          ? null
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [displayIcon(walk)]),
      title: Text(walk.city),
      subtitle: Text(walk.province),
      enabled: !walk.isCancelled(),
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (context) => WalkDetailsView(walk))),
      trailing: walk.isCancelled() ? Text("Annulé") : GeoButton(walk: walk),
    );
  }
}
