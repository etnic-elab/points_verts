import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:points_verts/walk_list_error.dart';
import 'package:points_verts/walk_tile.dart';

import 'loading.dart';
import 'walk.dart';
import 'walk_list.dart';

class WalkResultsListView extends StatelessWidget {
  WalkResultsListView(
      this.walks, this.position, this.currentPlace, this.refreshWalks);

  final Future<List<Walk>> walks;
  final Position position;
  final Places currentPlace;
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
                  return WalkTile(walk: snapshot.data[i]);
                },
                itemCount: snapshot.data.length);
          } else if (snapshot.hasError) {
            return WalkListError(refreshWalks);
          } else {
            return Loading();
          }
        } else {
          return Loading();
        }
      },
    );
  }
}
