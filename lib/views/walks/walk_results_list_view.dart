import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:points_verts/views/walks/walk_list_error.dart';
import 'package:points_verts/views/walks/walk_results_list.dart';

import '../loading.dart';
import '../../models/walk.dart';
import 'walks_view.dart';

class WalkResultsListView extends StatelessWidget {
  const WalkResultsListView(
      this.walks, this.position, this.currentPlace, this.refreshWalks,
      {super.key});

  final Future<List<Walk>>? walks;
  final LatLng? position;
  final Places? currentPlace;
  final Function refreshWalks;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Walk>>(
      future: walks,
      initialData: const [],
      builder: (BuildContext context, AsyncSnapshot<List<Walk>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return WalkResultsList(snapshot.data!, position, currentPlace);
        }
        if (snapshot.hasError) {
          return WalkListError(refreshWalks);
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Loading(),
            Container(
                padding: const EdgeInsets.all(10),
                child: const Text("Chargement des marches..."))
          ],
        );
      },
    );
  }
}
