import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:points_verts/environment.dart';
import 'package:points_verts/services/assets.dart';
import 'package:points_verts/services/map/map_interface.dart';
import 'package:points_verts/services/map/markers/marker_interface.dart';
import 'package:points_verts/views/maps/google_map.dart';

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
      if (walk.isPositionable()) {
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
        if (walk.isPositionable() && distanceDuration?['status'] == 'OK') {
          walk.trip = Trip(
              distance: distanceDuration["distance"]["value"],
              duration: distanceDuration["duration"]["value"]);
        }
      } // update the trip distance/duration for each walk
    }
  }

  @override
  Widget retrieveMap(List<MarkerInterface> markers, Function onMapTap,
      {double centerLat = 50.3155646,
      double centerLong = 5.009682,
      double zoom = 7.5}) {
    return GoogleMap(markers, onMapTap, centerLat, centerLong, zoom);
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
  Widget retrieveStaticImage(
      double? long, double? lat, int width, int height, Brightness brightness,
      {double zoom = 16.0}) {
    {
      return FutureBuilder(
        future: Assets.instance.assetText(brightness, Assets.googleMapStatic),
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.hasData) {
            var body = {
              "size": "${width}x$height",
              "center": "$lat,$long",
              "markers": "color:blue|$lat,$long",
              "zoom": "13",
              "key": _apiKey
            };
            Uri url =
                Uri.https("maps.googleapis.com", "/maps/api/staticmap", body);
            String urlString = url.toString() + snapshot.data!;
            return CachedNetworkImage(
              imageUrl: urlString,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  Center(
                      child: CircularProgressIndicator(
                          value: downloadProgress.progress)),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            );
          }
          return const SizedBox.shrink();
        },
      );
    }
  }
}
