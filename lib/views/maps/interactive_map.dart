import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:maps_api/maps_api.dart';
import 'package:points_verts/views/maps/flutter_map.dart';
import 'package:points_verts/views/maps/google_map.dart';
import 'package:points_verts/views/maps/markers/marker_interface.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;
import 'package:points_verts/models/path.dart';

enum DisplayMapProvider { google, mapbox, azure }

class InteractiveMap {
  InteractiveMap({
    String? mapProvider,
    String? apiKey,
  })  : _mapProvider = mapProvider ?? dotenv.env['INTERACTIVE_MAP'] ?? '',
        _apiKey = apiKey ?? dotenv.env['INTERACTIVE_MAP_API_KEY'] ?? '';

  final String _mapProvider;
  final String _apiKey;

  static const Geolocation _defaultCenter =
      Geolocation(latitude: 50.3155646, longitude: 4.6);
  static const double _defaultZoom = 7.35;

  DisplayMapProvider get displayMapProvider {
    switch (_mapProvider.toLowerCase()) {
      case 'google':
        return DisplayMapProvider.google;
      case 'azure':
        return DisplayMapProvider.azure;
      case 'mapbox':
        return DisplayMapProvider.mapbox;
      default:
        throw ArgumentError(
            'Invalid displayMapProvider: $_mapProvider. Should be one of "google", "azure" or "mapbox"');
    }
  }

  Widget getMap({
    Geolocation? center,
    double? zoom,
    bool locationEnabled = false,
    List<MarkerInterface> markers = const [],
    List<Path> paths = const [],
    Function? onTapMap,
    Function(Path)? onTapPath,
  }) {
    center ??= _defaultCenter;
    zoom ??= _defaultZoom;

    switch (displayMapProvider) {
      case DisplayMapProvider.google:
        return _getGoogleMap(
          center: center,
          zoom: zoom,
          locationEnabled: locationEnabled,
          markers: markers,
          paths: paths,
          onTapMap: onTapMap,
          onTapPath: onTapPath,
        );
      case DisplayMapProvider.azure:
      case DisplayMapProvider.mapbox:
        return _getFlutterMap(
          center: center,
          zoom: zoom,
          markers: markers,
        );
    }
  }

  Widget _getGoogleMap({
    required Geolocation center,
    required double zoom,
    required bool locationEnabled,
    required List<MarkerInterface> markers,
    required List<Path> paths,
    required Function? onTapMap,
    required Function(Path)? onTapPath,
  }) {
    google.CameraPosition initialLocation = google.CameraPosition(
      target: google.LatLng(center.latitude, center.longitude),
      zoom: zoom,
    );

    return GoogleMap(
      initialLocation: initialLocation,
      locationEnabled: locationEnabled,
      paths: paths,
      markers: markers,
      onTapMap: onTapMap,
    );
  }

  Widget _getFlutterMap({
    required Geolocation center,
    required double zoom,
    required List<MarkerInterface> markers,
  }) {
    return FlutterMap(
      displayMapProvider,
      markers,
      _apiKey,
      center,
      zoom,
    );
  }
}
