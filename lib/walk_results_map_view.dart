import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';

import 'walk.dart';
import 'walk_utils.dart';

class WalkResultsMapView extends StatelessWidget {
  WalkResultsMapView(this.walks, this.currentPosition);

  final List<Walk> walks;
  final Position currentPosition;

  @override
  Widget build(BuildContext context) {
    List<Marker> markers = new List<Marker>();
    for (Walk walk in walks) {
      if (walk.lat != null && walk.long != null) {
        markers.add(Marker(
            point: new LatLng(walk.lat, walk.long),
            builder: (ctx) => new Container(
                  child: IconButton(
                    icon: displayIcon(walk),
                    tooltip: walk.city,
                    onPressed: () {
                      launchMaps(walk);
                    },
                  ),
                )));
      }
    }
    if (currentPosition != null) {
      markers.add(Marker(
        point: new LatLng(currentPosition.latitude, currentPosition.longitude),
        builder: (ctx) => new Container(child: Icon(Icons.location_on)),
      ));
    }
    return new FlutterMap(
      options: new MapOptions(
        center: currentPosition != null
            ? LatLng(currentPosition.latitude, currentPosition.longitude)
            : new LatLng(50.7372, 4.6828),
        zoom: currentPosition != null ? 9 : 7.5,
      ),
      layers: [
        new TileLayerOptions(
          urlTemplate: "https://api.tiles.mapbox.com/v4/"
              "{id}/{z}/{x}/{y}@2x.png?access_token={accessToken}",
          additionalOptions: {
            'accessToken':
                'pk.eyJ1IjoidGJvcmxlZSIsImEiOiJjazRvNGI4ZXAycTBtM2txd2Z3eHk3Ymh1In0.12yn8XMdhqdoPByYti4g5g',
            'id': 'mapbox.streets',
          },
        ),
        new MarkerLayerOptions(markers: markers),
      ],
    );
  }
}
