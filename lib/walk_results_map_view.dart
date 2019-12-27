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
          width: 25,
          height: 25,
          point: new LatLng(walk.lat, walk.long),
          builder: (ctx) => RawMaterialButton(
            child: displayIcon(walk, color: Colors.white, size: 20),
            shape: new CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.green,
            onPressed: () {
              if(walk.status != 'ptvert_annule') {
                launchMaps(walk);
              }
            },
          ),
        ));
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
        center: new LatLng(50.3155646,5.009682),
        zoom: 7.5,
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
