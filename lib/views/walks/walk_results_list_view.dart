import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:points_verts/views/walks/walk_list_error.dart';
import 'package:points_verts/views/walks/walk_results_list.dart';

import '../loading.dart';
import '../../models/walk.dart';
import '../../models/coordinates.dart';
import 'walks_view.dart';

class WalkResultsListView extends StatelessWidget {
  WalkResultsListView(
      this.walks, this.position, this.currentPlace, this.refreshWalks);

  final Future<List<Walk>>? walks;
  final Coordinates? position;
  final Places? currentPlace;
  final Function refreshWalks;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Walk>>(
      future: walks,
      initialData: [],
      builder: (BuildContext context, AsyncSnapshot<List<Walk>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return WalkResultsList(snapshot.data!, position, currentPlace);
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
}
