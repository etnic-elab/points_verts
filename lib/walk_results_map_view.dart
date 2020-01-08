import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:points_verts/geo_button.dart';

import 'walk.dart';
import 'walk_utils.dart';

class WalkResultsMapView extends StatelessWidget {
  WalkResultsMapView(this.walks, this.currentPosition,
      this.selectedWalk, this.onWalkSelect);

  final Widget loading = Center(
    child: new CircularProgressIndicator(),
  );

  final Future<List<Walk>> walks;
  final Position currentPosition;
  final Walk selectedWalk;
  final Function(Walk) onWalkSelect;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: walks,
      builder: (BuildContext context, AsyncSnapshot<List<Walk>> snapshot) {
        if (snapshot.hasData) {
          List<Marker> markers = new List<Marker>();
          for (Walk walk in snapshot.data) {
            if (walk.lat != null && walk.long != null) {
              markers.add(_buildMarker(walk, context));
            }
          }
          if (currentPosition != null) {
            markers.add(Marker(
              point: new LatLng(
                  currentPosition.latitude, currentPosition.longitude),
              builder: (ctx) => new Container(child: Icon(Icons.location_on)),
            ));
          }

          return Stack(
            children: <Widget>[
              _buildFlutterMap(
                  markers, MediaQuery.of(context).platformBrightness),
              _buildWalkInfo(selectedWalk),
            ],
          );
        } else {
          return loading;
        }
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
                  height: 50.0,
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      displayIcon(walk),
                      _buildWalkInfoLabel(walk),
                      walk.isCancelled()
                          ? SizedBox.shrink()
                          : GeoButton(walk: walk)
                    ],
                  ),
                ),
              )));
    }
  }

  static Widget _buildWalkInfoLabel(Walk walk) {
    if (walk.isCancelled()) {
      return Text('${walk.city} (annulé)');
    } else if (walk.distance != null) {
      return Column(
        children: <Widget>[
          Spacer(),
          Text(walk.city),
          Text(walk.getFormattedDistance()),
          Spacer()
        ],
      );
    } else {
      return Text(walk.city);
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

  static _buildFlutterMap(List<Marker> markers, Brightness brightness) {
    return FlutterMap(
      options: new MapOptions(
        center: new LatLng(50.3155646, 5.009682),
        zoom: 7.5,
      ),
      layers: [
        new TileLayerOptions(
          urlTemplate: "https://api.tiles.mapbox.com/v4/"
              "{id}/{z}/{x}/{y}@2x.png?access_token={accessToken}",
          additionalOptions: {
            'accessToken':
                'pk.eyJ1IjoidGJvcmxlZSIsImEiOiJjazRvNGI4ZXAycTBtM2txd2Z3eHk3Ymh1In0.12yn8XMdhqdoPByYti4g5g',
            'id': brightness == Brightness.dark
                ? 'mapbox.dark'
                : 'mapbox.streets',
          },
        ),
        new MarkerLayerOptions(markers: markers),
      ],
    );
  }
}
