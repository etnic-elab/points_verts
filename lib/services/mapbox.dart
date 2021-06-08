import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/address_suggestion.dart';
import '../models/trip.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/walk.dart';
import 'trip_cache_manager.dart';

String? _token = dotenv.env['MAPBOX_TOKEN'];

Future<void> retrieveTrips(
    double fromLong, double fromLat, List<Walk> walks) async {
  String origin = "$fromLong,$fromLat";
  String destinations = "";
  for (int i = 0; i < min(walks.length, 5); i++) {
    Walk walk = walks[i];
    if (walk.isPositionable()) {
      destinations = destinations + ";${walk.long},${walk.lat}";
    }
  }
  if (destinations.isEmpty) {
    return;
  }
  final String url =
      "https://api.mapbox.com/directions-matrix/v1/mapbox/driving/$origin$destinations?sources=0&annotations=distance,duration&access_token=$_token";
  final http.Response response = await TripCacheManager.getData(url);
  final decoded = json.decode(response.body);
  final distances =
      decoded['distances']?.length == 1 ? decoded['distances'][0] : null;
  final durations =
      decoded['durations']?.length == 1 ? decoded['durations'][0] : null;
  if (distances != null && durations != null) {
    for (int i = 0; i < min(walks.length, 5); i++) {
      Walk walk = walks[i];
      if (walk.isPositionable() && distances.length >= i) {
        walk.trip =
            Trip(distance: distances[i + 1], duration: durations[i + 1]);
      }
    }
  }
}

Widget retrieveMap(List<Marker> markers, Brightness brightness,
    {double centerLat = 50.3155646,
    double centerLong = 5.009682,
    double zoom = 7.5,
    interactive = InteractiveFlag.all}) {
  return FlutterMap(
    options: new MapOptions(
        center: LatLng(centerLat, centerLong),
        zoom: zoom,
        interactiveFlags: interactive),
    layers: [
      new TileLayerOptions(
        urlTemplate:
            "https://api.mapbox.com/styles/v1/mapbox/{id}/tiles/{z}/{x}/{y}@2x?access_token={accessToken}",
        tileSize: 512,
        maxZoom: 18,
        zoomOffset: -1,
        additionalOptions: {
          'accessToken': _token!,
          'id': brightness == Brightness.dark ? 'dark-v10' : 'light-v10',
        },
      ),
      new MarkerLayerOptions(markers: markers),
    ],
  );
}

Future<List<AddressSuggestion>> retrieveSuggestions(
    String country, String search) async {
  if (search.isNotEmpty) {
    final String url =
        "https://api.mapbox.com/geocoding/v5/mapbox.places/$search.json?access_token=$_token&country=$country&language=fr_BE&limit=10&types=address,poi";
    final http.Response response = await http.get(Uri.parse(url));
    var decoded = json.decode(response.body);
    List<AddressSuggestion> results = [];
    if (decoded['features'] != null) {
      for (var result in decoded['features']) {
        results.add(AddressSuggestion(
            text: result['text'],
            address: result['place_name'],
            longitude: result['center'][0],
            latitude: result['center'][1]));
      }
    }
    return results;
  } else {
    return [];
  }
}

Future<String?> retrieveAddress(double long, double lat) async {
  final String url =
      "https://api.mapbox.com/geocoding/v5/mapbox.places/$long,$lat.json?access_token=$_token";
  final http.Response response = await http.get(Uri.parse(url));
  var decoded = json.decode(response.body);
  if (decoded['features'].length > 0) {
    return decoded['features'][0]['place_name'];
  } else {
    return null;
  }
}

Widget retrieveStaticImage(
    double? long, double? lat, int width, int height, Brightness brightness,
    {double zoom = 16.0}) {
  final String style = brightness == Brightness.dark ? 'dark-v10' : 'light-v10';
  Uri url = Uri.parse(
      "https://api.mapbox.com/styles/v1/mapbox/$style/static/pin-l($long,$lat)/$long,$lat,$zoom,0,0/${width}x$height@2x?access_token=$_token");
  return CachedNetworkImage(
    imageUrl: url.toString(),
    progressIndicatorBuilder: (context, url, downloadProgress) => Center(
        child: CircularProgressIndicator(value: downloadProgress.progress)),
    errorWidget: (context, url, error) => Icon(Icons.error),
  );
}
