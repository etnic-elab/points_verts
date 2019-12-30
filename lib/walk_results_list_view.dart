import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'walk.dart';
import 'walk_utils.dart';

class WalkResultsListView extends StatelessWidget {
  WalkResultsListView(this.walks, this.isLoading);

  final Widget loading = Center(
    child: Platform.isIOS ? CupertinoActivityIndicator() : CircularProgressIndicator(),
  );

  final List<Walk> walks;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loading;
    } else {
      return ListView.separated(
          separatorBuilder: (context, i) => Divider(),
          itemBuilder: (context, i) {
            if (walks.length > i) {
              Walk walk = walks[i];
              return ListTile(
                leading: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [displayIcon(walk)]),
                title: Text(walk.city),
                subtitle: Text(walk.province),
                enabled: !walk.isCancelled(),
                trailing:  walk.isCancelled() ? Text("Annulé") : _displayDistance(walk),
                onTap: () => launchGeoApp(walk),
              );
            } else {
              return SizedBox.shrink();
            }
          },
          itemCount: walks.length);
    }
  }

  _displayDistance(Walk walk) {
    if (walk.distance != null) {
      return Text(walk.getFormattedDistance());
    } else {
      return SizedBox.shrink();
    }
  }
}
