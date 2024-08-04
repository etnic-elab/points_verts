import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:points_verts/models/address.dart';
import 'package:points_verts/models/path.dart';
import 'package:points_verts/models/walk.dart';
import 'package:points_verts/services/map/map_interface.dart';
import 'package:points_verts/services/map/markers/marker_interface.dart';

import '../../models/trip.dart';
import '../../views/maps/flutter_map.dart';
import '../firebase.dart';
import 'package:http/http.dart' as http;

class AzureMaps extends MapInterface {
  @override
  String get name => "Azure";

  @override
  String get apiName => "AZUREMAPS_API_KEY";

  @override
  String get website =>
      "https://azure.microsoft.com/en-gb/products/azure-maps/";

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
    return FlutterMap(
        Maps.azure, markers, apiKey!, centerLat, centerLong, zoom);
  }

  @override
  Future<Address?> retrievePlaceDetailFromId(String placeId,
      {String? sessionToken}) {
    throw UnimplementedError();
  }

  @override
  Widget retrieveStaticImage(
      Walk walk, int width, int height, Brightness brightness,
      {double zoom = 16, Function? onTap}) {
    Uri url = Uri.parse(
        "https://atlas.microsoft.com/map/static?api-version=2024-04-01&zoom=${zoom.toInt()}&pins=default||${walk.long} ${walk.lat}&center=${walk.long},${walk.lat}&height=$height&width=$width&language=fr&subscription-key=$apiKey");
    return CachedNetworkImage(
      imageUrl: url.toString(),
      progressIndicatorBuilder: (context, url, downloadProgress) => Center(
          child: CircularProgressIndicator(value: downloadProgress.progress)),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }

  @override
  Future<List<AddressSuggestion>> retrieveSuggestions(
      String search, String country,
      {String? sessionToken}) async {
    final String url =
        "https://atlas.microsoft.com/geocode?api-version=2023-06-01&countryRegion=$country&top=10&addressLine=$search&subscription-key=$apiKey";
    final http.Response response = await http.get(Uri.parse(url));
    var decoded = json.decode(response.body);
    List<AddressSuggestion> results = [];
    if (decoded['features'] != null) {
      for (var result in decoded['features']) {
        results.add(AddressSuggestion(
            "",
            result['properties']['address']['addressLine'],
            result['properties']['address']['formattedAddress'],
            result['geometry']['coordinates'][0],
            result['geometry']['coordinates'][1]));
      }
    }
    return results;
  }

  @override
  Future<void> retrieveTrips(
      double fromLong, double fromLat, List<Walk> walks) async {
    var destinationsList = [];
    int numberOfTrips =
        FirebaseLocalService.firebaseRemoteConfigService!.getNumberOfTrips();

    for (int i = 0; i < min(walks.length, numberOfTrips); i++) {
      Walk walk = walks[i];
      if (walk.isPositionable) {
        destinationsList.add([walk.long, walk.lat]);
      }
    }

    if (destinationsList.isEmpty) {
      return;
    }

    var body = {
      "origins": {
        "type": "MultiPoint",
        "coordinates": [
          [fromLong, fromLat]
        ]
      },
      "destinations": {"type": "MultiPoint", "coordinates": destinationsList},
    };

    final String url =
        "https://atlas.microsoft.com/route/matrix/sync/json?api-version=1.0&subscription-key=$apiKey";
    final http.Response response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(body));
    final decoded = json.decode(response.body);
    final distanceDurations = decoded["matrix"][0];

    if (!distanceDurations?.isEmpty) {
      for (int i = 0; i < min(walks.length, numberOfTrips); i++) {
        var distanceDuration = distanceDurations[i];
        Walk walk = walks[i];
        if (walk.isPositionable && distanceDuration?['statusCode'] == 200) {
          walk.trip = Trip(
              distance: distanceDuration["response"]["routeSummary"]
                  ["lengthInMeters"],
              duration: distanceDuration["response"]["routeSummary"]
                  ["travelTimeInSeconds"]);
        }
      }
    }
  }
}
