import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:points_verts/environment.dart';
import 'package:points_verts/models/path.dart';
import 'package:points_verts/services/map/map_interface.dart';
import 'package:points_verts/services/map/markers/marker_interface.dart';
import 'package:points_verts/views/maps/flutter_map.dart';
import 'package:points_verts/extensions.dart';

import '../../models/address.dart';
import '../../models/trip.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../models/walk.dart';
import '../cache_managers/trip_cache_manager.dart';

class MapBox implements MapInterface {
  final String? _token = Environment.mapApiKey;

  @override
  Future<void> retrieveTrips(
      double fromLong, double fromLat, List<Walk> walks) async {
    String origin = "$fromLong,$fromLat";
    String destinations = "";
    for (int i = 0; i < min(walks.length, 5); i++) {
      Walk walk = walks[i];
      if (walk.isPositionable) {
        destinations = "$destinations;${walk.long},${walk.lat}";
      }
    }
    if (destinations.isEmpty) {
      return;
    }
    final String url =
        "https://api.mapbox.com/directions-matrix/v1/mapbox/driving/$origin$destinations?sources=0&annotations=distance,duration&access_token=$_token";
    final http.Response response = await TripCacheManager.trip.getData(url);
    final decoded = json.decode(response.body);
    final distances =
        decoded['distances']?.length == 1 ? decoded['distances'][0] : null;
    final durations =
        decoded['durations']?.length == 1 ? decoded['durations'][0] : null;
    if (distances != null && durations != null) {
      for (int i = 0; i < min(walks.length, 5); i++) {
        Walk walk = walks[i];
        if (walk.isPositionable && distances.length >= i) {
          walk.trip =
              Trip(distance: distances[i + 1], duration: durations[i + 1]);
        }
      }
    }
  }

  @override
  Future<List<AddressSuggestion>> retrieveSuggestions(
      String search, String country,
      {String? sessionToken}) async {
    final String url =
        "https://api.mapbox.com/geocoding/v5/mapbox.places/$search.json?access_token=$_token&country=$country&language=fr_BE&limit=10&types=address,poi";
    final http.Response response = await http.get(Uri.parse(url));
    var decoded = json.decode(response.body);
    List<AddressSuggestion> results = [];
    if (decoded['features'] != null) {
      for (var result in decoded['features']) {
        results.add(AddressSuggestion(
            result['id'], result['test'], result['place_name']));
      }
    }
    return results;
  }

  @override
  Future<Address?> retrievePlaceDetailFromId(String placeId) {
    throw UnsupportedError;
  }

  @override
  Widget retrieveMap({
    double centerLat = MapInterface.defaultLat,
    double centerLong = MapInterface.defaultLong,
    double zoom = MapInterface.defaultZoom,
    locationEnabled = false,
    List<MarkerInterface> markers = const [],
    List<Path> paths = const [],
    Function? onTapMap,
    Function(Path)? onTapPath,
  }) {
    return FlutterMap(markers, _token!, centerLat, centerLong, zoom);
  }

  String _getEncodedPath(List<Path> paths, Brightness brightness) {
    return paths
        .map((path) {
          List<List<num>> encodable = path.encodablePoints;
          return encodable.isNotEmpty
              ? "path-2+${path.getColor(brightness).toHex()}-1(${Uri.encodeComponent(encodePolyline(encodable))})"
              : null;
        })
        .whereType<String>()
        .toList()
        .join(',');
  }

  @override
  Widget retrieveStaticImage(
      Walk walk, int width, int height, Brightness brightness,
      {double zoom = 16.0, Function? onTap}) {
    final String style =
        brightness == Brightness.dark ? 'dark-v10' : 'light-v10';
    final String path = _getEncodedPath(walk.paths, brightness);
    Uri url = Uri.parse(
        "https://api.mapbox.com/styles/v1/mapbox/$style/static/pin-l(${walk.long},${walk.lat})$path/auto/${width}x$height@2x?access_token=$_token");
    return CachedNetworkImage(
      imageUrl: url.toString(),
      progressIndicatorBuilder: (context, url, downloadProgress) => Center(
          child: CircularProgressIndicator(value: downloadProgress.progress)),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}
