import 'dart:async';
import 'dart:math';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:points_verts/models/path.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;
import 'package:points_verts/company_data.dart';
import 'package:points_verts/environment.dart';
import 'package:points_verts/services/map/map_interface.dart';
import 'package:points_verts/services/map/markers/marker_interface.dart';
import 'package:points_verts/views/maps/google_map.dart';
import 'package:points_verts/extensions.dart';
import 'package:points_verts/views/maps/google_static_image.dart';

import '../../models/address_suggestion.dart';
import '../../models/trip.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../models/walk.dart';
import '../cache_managers/trip_cache_manager.dart';

class GoogleMaps implements MapInterface {
  final String? _apiKey = Environment.mapApiKey;

  @override
  Future<void> retrieveTrips(
      double fromLong, double fromLat, List<Walk> walks) async {
    String origin = "$fromLat,$fromLong";
    var destinationsList = [];

    for (int i = 0; i < min(walks.length, 5); i++) {
      Walk walk = walks[i];
      if (walk.isPositionable) {
        destinationsList.add("${walk.lat},${walk.long}");
      }
    }

    if (destinationsList.isEmpty) {
      return;
    }

    var body = {
      "origins": origin,
      "destinations": destinationsList.join("|"),
      "key": _apiKey
    };

    final String url =
        Uri.https("maps.googleapis.com", "/maps/api/distancematrix/json", body)
            .toString();
    final http.Response response = await TripCacheManager.trip.getData(url);
    final decoded = json.decode(response.body);
    final distanceDurations = decoded["rows"]?[0]?["elements"];

    if (!distanceDurations?.isEmpty) {
      for (int i = 0; i < min(walks.length, 5); i++) {
        var distanceDuration = distanceDurations[i];
        Walk walk = walks[i];
        if (walk.isPositionable && distanceDuration?['status'] == 'OK') {
          walk.trip = Trip(
              distance: distanceDuration["distance"]["value"],
              duration: distanceDuration["duration"]["value"]);
        }
      } // update the trip distance/duration for each walk
    }
  }

  @override
  Future<List<AddressSuggestion>> retrieveSuggestions(
      String country, String search) async {
    if (search.isNotEmpty) {
      var body = {"query": search, "key": _apiKey};
      Uri url = Uri.https(
          "maps.googleapis.com", "/maps/api/place/textsearch/json", body);
      http.Response response = await http.get(url);
      var decoded = json.decode(response.body);
      List<AddressSuggestion> results = [];
      if (decoded['results'] != null) {
        for (var prediction in decoded['results']) {
          results.add(AddressSuggestion(
              text: prediction['name'],
              address: prediction['formatted_address'],
              longitude: prediction['geometry']['location']['lng'],
              latitude: prediction['geometry']['location']['lat']));
        }
      }
      return results;
    } else {
      return [];
    }
  }

  @override
  Future<String?> retrieveAddress(double long, double lat) async {
    var body = {
      "latlng": lat.toString() + "," + long.toString(),
      "key": _apiKey
    };
    Uri url = Uri.https("maps.googleapis.com", "/maps/api/geocode/json", body);
    http.Response response = await http.get(url);
    var decoded = json.decode(response.body);
    if (decoded['results'].length > 0) {
      return decoded['results'][0]['formatted_address'];
    } else {
      return null;
    }
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
    google.CameraPosition _initialLocation = google.CameraPosition(
        target: google.LatLng(centerLat, centerLong), zoom: zoom);

    return GoogleMap(
      initialLocation: _initialLocation,
      locationEnabled: locationEnabled,
      paths: paths,
      markers: markers,
      onTapMap: onTapMap,
      // onTapPath: onTapPath,
    );
  }

  @override
  Widget retrieveStaticImage(
      Walk walk, int width, int height, Brightness brightness,
      {double? zoom, Function? onTap}) {
    {
      Map<String, dynamic> body = {};
      body['size'] = '${width}x$height';
      body['scale'] = '2';
      body['key'] = _apiKey;
      body['path'] = _getPaths(walk.paths, brightness);
      body = _addMarkers(body, walk, brightness);

      Uri url = Uri.https("maps.googleapis.com", "/maps/api/staticmap", body);

      return GoogleStaticImage(url.toString(), onTap);
    }
  }

  List<String> _getPaths(List<Path> paths, Brightness brightness) {
    return paths
        .map((Path _path) {
          List<List<num>> _encodable = _path.encodablePoints;

          return _encodable.isNotEmpty
              ? [
                  'color:${_path.getColor(brightness).toHex(transparancy: true)}',
                  'weight:2',
                  'enc:${encodePolyline(_encodable)}'
                ].join('|')
              : null;
        })
        .whereType<String>()
        .toList();
  }

  Map<String, dynamic> _addMarkers(
      Map<String, dynamic> body, Walk walk, Brightness brightness) {
    if (walk.hasPosition) {
      String logoUrl = walk.isCancelled
          ? brightness == Brightness.dark
              ? publicLogoCancelledDark
              : publicLogoCancelledLight
          : publicLogo;
      body['markers'] =
          'scale:2|anchor:center|icon:$logoUrl|${walk.lat},${walk.long}';
    } else {
      body['center'] = '${MapInterface.defaultLat},${MapInterface.defaultLong}';
      body['zoom'] = '${MapInterface.defaultZoom}';
    }

    return body;
  }
}
