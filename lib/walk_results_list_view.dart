import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'walk.dart';
import 'walk_utils.dart';

class WalkResultsListView extends StatelessWidget {
  WalkResultsListView(this.walks, this.isLoading);

  final Widget loading = Center(
    child: new CircularProgressIndicator(),
  );

  final List<Walk> walks;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loading;
    } else {
      return ListView.builder(
          itemBuilder: (context, i) {
            if (walks.length > i) {
              Walk walk = walks[i];
              return Card(
                  child: ListTile(
                leading: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [_displayIcon(walk)]),
                title: Text(walk.city),
                subtitle: Text(walk.province),
                enabled: walk.status != 'ptvert_annule',
                trailing:  walk.status != 'ptvert_annule' ? _displayDistance(walk) : Text("Annulé"),
                onTap: () => launchGeoApp(walk),
              ));
            } else {
              return SizedBox.shrink();
            }
          },
          itemCount: walks.length);
    }
  }

  _displayIcon(walk) {
    if (walk.status == 'ptvert_annule') {
      return Icon(Icons.cancel);
    } else if (walk.type == 'M') {
      return Icon(Icons.directions_walk);
    } else if (walk.type == 'O') {
      return Icon(Icons.map);
    } else {
      return SizedBox.shrink();
    }
  }

  _displayDistance(walk) {
    if (walk.distance != null) {
      return Text((walk.distance / 1000).round().toString() + " km");
    } else {
      return SizedBox.shrink();
    }
  }
}
