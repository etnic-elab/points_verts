import 'dart:async';
import 'dart:math';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:points_verts/models/path.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;
import 'package:points_verts/company_data.dart';
import 'package:points_verts/services/map/map_interface.dart';
import 'package:points_verts/services/map/markers/marker_interface.dart';
import 'package:points_verts/views/maps/google_map.dart';
import 'package:points_verts/extensions.dart';
import 'package:points_verts/views/maps/google_static_map.dart';

import '../../models/address.dart';
import '../../models/trip.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../models/walk.dart';
import '../cache_managers/trip_cache_manager.dart';

const int numberOfTrips = 2;

class GoogleMaps extends MapInterface {
  @override
  String get name => "Google";
  @override
  String get apiName => "GOOGLEMAPS_API_KEY";
  @override
  String get website => "https://mapsplatform.google.com";

  @override
  Future<void> retrieveTrips(
      double fromLong, double fromLat, List<Walk> walks) async {
    String origin = "$fromLat,$fromLong";
    var destinationsList = [];

    for (int i = 0; i < min(walks.length, numberOfTrips); i++) {
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
      "key": apiKey
    };

    final String url =
        Uri.https("maps.googleapis.com", "/maps/api/distancematrix/json", body)
            .toString();
    final http.Response response = await TripCacheManager.trip.getData(url);
    final decoded = json.decode(response.body);
    final distanceDurations = decoded["rows"]?[0]?["elements"];

    if (!distanceDurations?.isEmpty) {
      for (int i = 0; i < min(walks.length, numberOfTrips); i++) {
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
      String search, String country,
      {String? sessionToken}) async {
    var body = {
      "input": search,
      "types": "address",
      "components": "country:$country",
      "language": "fr",
      "key": apiKey,
      if (sessionToken != null) "sessiontoken": sessionToken,
    };
    final request = Uri.https(
        "maps.googleapis.com", "/maps/api/place/autocomplete/json", body);
    final response = await http.get(request);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        // compose suggestions in a list
        return result['predictions']
            .map<AddressSuggestion>((p) => AddressSuggestion(p['place_id'],
                p['structured_formatting']['main_text'], p['description']))
            .toList();
      }
    }

    return [];
  }

  @override
  Future<Address?> retrievePlaceDetailFromId(String placeId,
      {String? sessionToken}) async {
    var body = {
      "place_id": placeId,
      "fields": "formatted_address,geometry/location",
      "language": "fr",
      "key": apiKey,
      if (sessionToken != null) "sessiontoken": sessionToken,
    };
    final request =
        Uri.https("maps.googleapis.com", "/maps/api/place/details/json", body);
    final response = await http.get(request);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        return Address(
            address: result['result']['formatted_address'],
            latitude: result['result']['geometry']['location']['lat'],
            longitude: result['result']['geometry']['location']['lng']);
      }
    }

    return null;
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
    google.CameraPosition initialLocation = google.CameraPosition(
        target: google.LatLng(centerLat, centerLong), zoom: zoom);

    return GoogleMap(
      initialLocation: initialLocation,
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
      body['language'] = 'fr';
      body['key'] = apiKey;
      body['path'] = _getPaths(walk.paths, brightness);
      body = _addMarkers(body, walk, brightness);

      Uri url = Uri.https("maps.googleapis.com", "/maps/api/staticmap", body);

      return GoogleStaticMap(url.toString(), onTap);
    }
  }

  List<String> _getPaths(List<Path> paths, Brightness brightness) {
    return paths
        .map((Path path) {
          List<List<num>> encodable = path.encodablePoints;

          return encodable.isNotEmpty
              ? [
                  'color:${path.getColor(brightness).toHex(transparancy: true)}',
                  'weight:2',
                  'enc:${encodePolyline(encodable)}'
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
