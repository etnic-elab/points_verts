import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutter;
import 'package:latlong2/latlong.dart';
import 'package:maps_api/maps_api.dart';
import 'package:points_verts/views/maps/interactive_map.dart';
import 'package:points_verts/views/maps/markers/marker_interface.dart';

String getUrlTemplate(DisplayMapProvider maps) {
  if (maps == DisplayMapProvider.mapbox) {
    return 'https://api.mapbox.com/styles/v1/mapbox/{id}/tiles/{z}/{x}/{y}@2x?access_token={accessToken}';
  } else if (maps == DisplayMapProvider.azure) {
    return 'https://atlas.microsoft.com/map/tile?api-version=2022-08-01&tilesetId={tilesetId}&zoom={z}&x={x}&y={y}&tileSize={tileSize}&language={language}&view={view}&subscription-key={subscriptionKey}';
  } else {
    throw UnsupportedError('flutter_map does not support $maps.');
  }
}

Map<String, String> getAdditionalOptions(
    DisplayMapProvider maps, BuildContext context, String token,) {
  if (maps == DisplayMapProvider.mapbox) {
    return {
      'accessToken': token,
      'id': Theme.of(context).brightness == Brightness.light
          ? 'light-v10'
          : 'dark-v10',
    };
  } else if (maps == DisplayMapProvider.azure) {
    return {
      'tileSize': '512',
      'language': 'fr',
      'view': 'Auto',
      'authType': 'subscriptionKey',
      'subscriptionKey': token,
      'tilesetId': Theme.of(context).brightness == Brightness.light
          ? 'microsoft.base.road'
          : 'microsoft.base.grayscale_dark',
    };
  } else {
    throw UnsupportedError('flutter_map does not support $maps.');
  }
}

///TODO: Should support paths. Not sure if it is possible
class FlutterMap extends StatelessWidget {
  const FlutterMap(
    this.displayMapProvider,
    this.markers,
    this.token,
    this.center,
    this.zoom, {
    super.key,
  });

  final DisplayMapProvider displayMapProvider;
  final List<MarkerInterface> markers;
  final String token;
  final Geolocation center;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    final flutterMarkers = <flutter.Marker>[];
    for (final marker in markers) {
      flutterMarkers.add(marker.buildFlutterMarker());
    }
    return flutter.FlutterMap(
      options: flutter.MapOptions(
          initialCenter: LatLng(
            center.latitude,
            center.longitude,
          ),
          initialZoom: zoom,),
      children: [
        flutter.TileLayer(
          urlTemplate: getUrlTemplate(displayMapProvider),
          tileSize: 512,
          maxZoom: 18,
          zoomOffset: displayMapProvider == DisplayMapProvider.mapbox ? -1 : 0,
          additionalOptions:
              getAdditionalOptions(displayMapProvider, context, token),
        ),
        flutter.MarkerLayer(markers: flutterMarkers),
      ],
    );
  }
}
