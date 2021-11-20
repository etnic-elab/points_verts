import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutter;
import 'package:points_verts/services/map/markers/marker_interface.dart';
import 'package:latlong2/latlong.dart';

class FlutterMap extends StatelessWidget {
  const FlutterMap(
      this.markers, this.token, this.centerLat, this.centerLong, this.zoom,
      {Key? key})
      : super(key: key);

  final List<MarkerInterface> markers;
  final String token;
  final double centerLat;
  final double centerLong;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    final List<flutter.Marker> _flutterMarkers = [];
    for (MarkerInterface marker in markers) {
      _flutterMarkers.add(marker.buildFlutterMarker());
    }
    return flutter.FlutterMap(
      options:
          flutter.MapOptions(center: LatLng(centerLat, centerLong), zoom: zoom),
      layers: [
        flutter.TileLayerOptions(
          urlTemplate:
              "https://api.mapbox.com/styles/v1/mapbox/{id}/tiles/{z}/{x}/{y}@2x?access_token={accessToken}",
          tileSize: 512,
          maxZoom: 18,
          zoomOffset: -1,
          additionalOptions: {
            'accessToken': token,
            'id': Theme.of(context).brightness == Brightness.dark
                ? 'dark-v10'
                : 'light-v10',
          },
        ),
        flutter.MarkerLayerOptions(markers: _flutterMarkers),
      ],
    );
  }
}
