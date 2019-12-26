import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import 'walk.dart';

class WalkResultsListView extends StatelessWidget {
  WalkResultsListView(this.walks);

  final List<Walk> walks;

  @override
  Widget build(BuildContext context) {
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
              trailing: _displayDistance(walk),
              onTap: () => _launchMaps(walk),
            ));
          } else {
            return SizedBox.shrink();
          }
        },
        itemCount: walks.length);
  }

  _displayIcon(walk) {
    if (walk.status == 'ptvert_annule') {
      return Icon(Icons.cancel);
    }
    else if (walk.type == 'M') {
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

  _launchMaps(Walk walk) async {
    String mapSchema = 'geo:${walk.lat},${walk.long}';
    if (await canLaunch(mapSchema)) {
      await launch(mapSchema);
    }
  }
}
