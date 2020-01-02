import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:points_verts/geo_button.dart';

import 'walk.dart';
import 'walk_utils.dart';

class WalkResultsListView extends StatelessWidget {
  WalkResultsListView(this.walks, this.userPosition, this.isLoading);

  final Widget loading = Center(
    child: Platform.isIOS
        ? CupertinoActivityIndicator()
        : CircularProgressIndicator(),
  );

  final List<Walk> walks;
  final Position userPosition;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loading;
    } else {
      return ListView.separated(
          separatorBuilder: (context, i) => Divider(height: 0.5),
          itemBuilder: (context, i) {
            if (userPosition != null) {
              if (i == 0) {
                return _buildListHeader(context, "Marches les plus proches");
              }
              if (i == 6) {
                return _buildListHeader(context, "Autres marches");
              }
              if (i < 6) {
                i = i - 1;
              } else {
                i = i - 2;
              }
            }
            if (walks.length > i) {
              return _buildListItem(context, walks[i]);
            } else {
              return SizedBox.shrink();
            }
          },
          itemCount: _defineItemCount());
    }
  }

  int _defineItemCount() {
    if (userPosition != null) {
      if(walks.length > 5) {
        return walks.length + 2;
      } else {
        return walks.length + 1;
      }
    } else {
      return walks.length;
    }
  }

  Widget _buildListHeader(BuildContext context, String title) {
    return Container(
      color: Colors.green,
      child: Center(
          child: Text(title,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ))),
      padding: EdgeInsets.all(10.0),
    );
  }

  Widget _buildListItem(BuildContext context, Walk walk) {
    bool smallScreen = window.physicalSize.width <= 640;
    return ListTile(
      dense: smallScreen,
      leading: smallScreen
          ? null
          : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [displayIcon(walk)]),
      title: Text(walk.city),
      subtitle: Text(subtitle(walk)),
      enabled: !walk.isCancelled(),
      trailing:
      walk.isCancelled() ? Text("Annulé") : GeoButton(walk: walk),
    );
  }

  String subtitle(Walk walk) {
    if (walk.trip != null) {
      return '${walk.province} - ${walk.getFormattedDistance()}';
    } else {
      return walk.province;
    }
  }
}
