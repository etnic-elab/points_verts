import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutter;
import 'package:points_verts/services/map/markers/marker_interface.dart';
import 'package:latlong2/latlong.dart';

import '../../services/map/map_interface.dart';

String getUrlTemplate(Maps maps) {
  if (maps == Maps.mapbox) {
    return "https://api.mapbox.com/styles/v1/mapbox/{id}/tiles/{z}/{x}/{y}@2x?access_token={accessToken}";
  } else if (maps == Maps.azure) {
    return "https://atlas.microsoft.com/map/tile?api-version=2022-08-01&tilesetId={tilesetId}&zoom={z}&x={x}&y={y}&tileSize={tileSize}&language={language}&view={view}&subscription-key={subscriptionKey}";
  } else {
    throw UnsupportedError("flutter_map does not support $maps.");
  }
}

Map<String, String> getAdditionalOptions(
    Maps maps, BuildContext context, String token) {
  if (maps == Maps.mapbox) {
    return {
      'accessToken': token,
      'id': Theme.of(context).brightness == Brightness.light
          ? "light-v10"
          : "dark-v10"
    };
  } else if (maps == Maps.azure) {
    return {
      'tileSize': '512',
      'language': 'fr',
      'view': 'Auto',
      'authType': 'subscriptionKey',
      'subscriptionKey': token,
      'tilesetId': Theme.of(context).brightness == Brightness.light
          ? "microsoft.base.road"
          : "microsoft.base.grayscale_dark"
    };
  } else {
    throw UnsupportedError("flutter_map does not support $maps.");
  }
}

class FlutterMap extends StatelessWidget {
  const FlutterMap(this.maps, this.markers, this.token, this.centerLat,
      this.centerLong, this.zoom,
      {super.key});

  final Maps maps;
  final List<MarkerInterface> markers;
  final String token;
  final double centerLat;
  final double centerLong;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    final List<flutter.Marker> flutterMarkers = [];
    for (MarkerInterface marker in markers) {
      flutterMarkers.add(marker.buildFlutterMarker());
    }
    return flutter.FlutterMap(
      options: flutter.MapOptions(
          initialCenter: LatLng(centerLat, centerLong), initialZoom: zoom),
      children: [
        flutter.TileLayer(
          urlTemplate: getUrlTemplate(maps),
          tileSize: 512,
          maxZoom: 18,
          zoomOffset: maps == Maps.mapbox ? -1 : 0,
          additionalOptions: getAdditionalOptions(maps, context, token),
        ),
        flutter.MarkerLayer(markers: flutterMarkers),
      ],
    );
  }
}
