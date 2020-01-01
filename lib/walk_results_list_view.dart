import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:points_verts/geo_button.dart';

import 'walk.dart';
import 'walk_utils.dart';

class WalkResultsListView extends StatelessWidget {
  WalkResultsListView(this.walks, this.isLoading);

  final Widget loading = Center(
    child: Platform.isIOS
        ? CupertinoActivityIndicator()
        : CircularProgressIndicator(),
  );

  final List<Walk> walks;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loading;
    } else {
      bool smallScreen = window.physicalSize.width <= 640;
      return ListView.separated(
          separatorBuilder: (context, i) => Divider(height: 1.0),
          itemBuilder: (context, i) {
            if (walks.length > i) {
              Walk walk = walks[i];
              return ListTile(
                dense: smallScreen,
                leading: smallScreen ? null : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [displayIcon(walk)]),
                title: Text(walk.city),
                subtitle: Text(subtitle(walk)),
                enabled: !walk.isCancelled(),
                trailing: walk.isCancelled()
                    ? Text("Annulé")
                    : GeoButton(walk: walk),
              );
            } else {
              return SizedBox.shrink();
            }
          },
          itemCount: walks.length);
    }
  }

  String subtitle(Walk walk) {
    if(walk.trip != null) {
      return '${walk.province} - ${walk.getFormattedDistance()}';
    } else {
      return walk.province;
    }
  }
}
