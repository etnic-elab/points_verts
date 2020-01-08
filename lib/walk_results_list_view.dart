import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:points_verts/geo_button.dart';
import 'package:points_verts/walk_list_error.dart';

import 'walk.dart';
import 'walk_utils.dart';

class WalkResultsListView extends StatelessWidget {
  WalkResultsListView(this.walks, this.userPosition, this.refreshWalks);

  final Widget loading = Center(
    child: Platform.isIOS
        ? CupertinoActivityIndicator()
        : CircularProgressIndicator(),
  );

  final Future<List<Walk>> walks;
  final Position userPosition;
  final Function refreshWalks;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Walk>>(
      future: walks,
      initialData: List<Walk>(),
      builder: (BuildContext context, AsyncSnapshot<List<Walk>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return ListView.separated(
                separatorBuilder: (context, i) => Divider(height: 0.5),
                itemBuilder: (context, i) {
                  if (userPosition != null) {
                    if (i == 0) {
                      return _buildListHeader(
                          context, "Points les plus proches");
                    }
                    if (i == 6) {
                      return _buildListHeader(context, "Autres points");
                    }
                    if (i < 6) {
                      i = i - 1;
                    } else {
                      i = i - 2;
                    }
                  }
                  if (snapshot.data.length > i) {
                    return _buildListItem(context, snapshot.data[i]);
                  } else {
                    return SizedBox.shrink();
                  }
                },
                itemCount: _defineItemCount(snapshot.data));
          } else if (snapshot.hasError) {
            return WalkListError(refreshWalks);
          } else {
            return loading;
          }
        } else {
          return loading;
        }
      },
    );
  }

  int _defineItemCount(List<Walk> walks) {
    if (userPosition != null) {
      if (walks.length == 0) {
        return walks.length;
      } else if (walks.length > 5) {
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
      color: Theme.of(context).primaryColor,
      child: Center(
          child:
              Text(title, style: Theme.of(context).primaryTextTheme.subtitle)),
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
      trailing: walk.isCancelled() ? Text("Annulé") : GeoButton(walk: walk),
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
