import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';

import '../loading.dart';
import '../../services/mapbox.dart';
import '../../models/walk.dart';
import 'walks_view.dart';
import 'walk_list_error.dart';
import 'walk_tile.dart';
import 'walk_utils.dart';

class WalkResultsMapView extends StatelessWidget {
  WalkResultsMapView(this.walks, this.position, this.currentPlace,
      this.selectedWalk, this.onWalkSelect, this.refreshWalks);

  final Future<List<Walk>> walks;
  final Position position;
  final Places currentPlace;
  final Walk selectedWalk;
  final Function(Walk) onWalkSelect;
  final Function refreshWalks;
  final List<Marker> markers = List<Marker>();

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: walks,
      builder: (BuildContext context, AsyncSnapshot<List<Walk>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            markers.clear();
            for (Walk walk in snapshot.data) {
              if (walk.lat != null && walk.long != null) {
                markers.add(_buildMarker(walk, context));
              }
            }
            if (position != null) {
              markers.add(Marker(
                point: new LatLng(position.latitude, position.longitude),
                builder: (ctx) => new Container(
                    child: Icon(currentPlace == Places.current
                        ? Icons.location_on
                        : Icons.home)),
              ));
            }

            return Stack(
              children: <Widget>[
                retrieveMap(markers, Theme.of(context).brightness),
                _buildWalkInfo(selectedWalk),
              ],
            );
          } else if (snapshot.hasError) {
            return WalkListError(refreshWalks);
          }
        }
        return Stack(
          children: <Widget>[
            retrieveMap(markers, Theme.of(context).brightness),
            Loading(),
            _buildWalkInfo(selectedWalk),
          ],
        );
      },
    );
  }

  static Widget _buildWalkInfo(Walk walk) {
    if (walk == null) {
      return SizedBox.shrink();
    } else {
      return SafeArea(
          child: Align(
              alignment: Alignment.bottomCenter,
              child: Card(
                child: Container(
                  child: WalkTile(walk: walk),
                ),
              )));
    }
  }

  Marker _buildMarker(Walk walk, BuildContext context) {
    return Marker(
      width: 25,
      height: 25,
      point: new LatLng(walk.lat, walk.long),
      builder: (ctx) => RawMaterialButton(
        child: displayIcon(walk, color: Colors.white, size: 20),
        shape: new CircleBorder(),
        elevation: selectedWalk == walk ? 5.0 : 2.0,
        // TODO: find a way to not hardcode the colors here
        fillColor: selectedWalk == walk ? Colors.greenAccent : Colors.green,
        onPressed: () {
          onWalkSelect(walk);
        },
      ),
    );
  }
}
