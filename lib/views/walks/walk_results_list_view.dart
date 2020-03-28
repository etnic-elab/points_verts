import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:points_verts/views/walks/walk_list_error.dart';
import 'package:points_verts/views/walks/walk_tile.dart';

import '../list_header.dart';
import '../loading.dart';
import '../../models/walk.dart';
import 'walks_view.dart';

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
                  if (position != null) {
                    if (i == 0) {
                      return ListHeader(_defineTopHeader());
                    }
                    if (i == 6) {
                      return ListHeader("Autres points");
                    }
                    if (i < 6) {
                      i = i - 1;
                    } else {
                      i = i - 2;
                    }
                  }
                  if (snapshot.data.length > i) {
                    return WalkTile(walk: snapshot.data[i]);
                  } else {
                    return SizedBox.shrink();
                  }
                },
                itemCount: _defineItemCount(snapshot.data));
          } else if (snapshot.hasError) {
            return WalkListError(refreshWalks);
          } else {
            return Loading();
          }
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Loading(),
              Container(
                  padding: EdgeInsets.all(10),
                  child: Text("Chargement des points..."))
            ],
          );
        }
      },
    );
  }

  String _defineTopHeader() {
    if (currentPlace == Places.home) {
      return "Points les plus proches du domicile";
    } else if (currentPlace == Places.current) {
      return "Points les plus proches de votre position";
    } else {
      return "Points les plus proches";
    }
  }

  int _defineItemCount(List<Walk> walks) {
    if (position != null) {
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
}
