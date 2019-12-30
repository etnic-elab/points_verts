import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';

import 'walk.dart';
import 'walk_utils.dart';

class WalkResultsMapView extends StatelessWidget {
  WalkResultsMapView(this.walks, this.currentPosition, this.isLoading,
      this.selectedWalk, this.onWalkSelect);

  final Widget loading = Center(
    child: new CircularProgressIndicator(),
  );

  final List<Walk> walks;
  final Position currentPosition;
  final bool isLoading;
  final Walk selectedWalk;
  final Function(Walk) onWalkSelect;

  @override
  Widget build(BuildContext context) {
    List<Marker> markers = new List<Marker>();
    for (Walk walk in walks) {
      if (walk.lat != null && walk.long != null) {
        markers.add(_buildMarker(walk, context));
      }
    }
    if (currentPosition != null) {
      markers.add(Marker(
        point: new LatLng(currentPosition.latitude, currentPosition.longitude),
        builder: (ctx) => new Container(child: Icon(Icons.location_on)),
      ));
    }

    return Stack(
      children: <Widget>[
        _buildFlutterMap(markers),
        _buildWalkInfo(selectedWalk),
        _buildLoading()
      ],
    );
  }

  Widget _buildLoading() {
    if (isLoading) {
      return loading;
    } else {
      return SizedBox.shrink();
    }
  }

  static Widget _buildWalkInfo(Walk walk) {
    if (walk == null) {
      return SizedBox.shrink();
    }
    bool cancelled = walk.status == "ptvert_annule";
    if (walk == null) {
      return SizedBox.shrink();
    } else {
      return Align(
          alignment: Alignment.bottomCenter,
          child: Card(
            child: Container(
              height: 50.0,
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  cancelled ? Text('${walk.city} (annulé)') : Text(walk.city),
                  cancelled
                      ? SizedBox.shrink()
                      : RaisedButton(
                          child: Text("S'Y RENDRE"),
                          onPressed: () {
                            launchGeoApp(walk);
                          },
                        )
                ],
              ),
            ),
          ));
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
        elevation: 2.0,
        fillColor: selectedWalk == walk ? Colors.greenAccent : Colors.green,
        onPressed: () {
          onWalkSelect(walk);
        },
      ),
    );
  }

  static _buildFlutterMap(List<Marker> markers) {
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
            'id': 'mapbox.streets',
          },
        ),
        new MarkerLayerOptions(markers: markers),
      ],
    );
  }
}
