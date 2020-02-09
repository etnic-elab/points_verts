import 'dart:math';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:points_verts/walk.dart';

import 'mapbox_suggestion.dart';
import 'trip.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

String _token = DotEnv().env['MAPBOX_TOKEN'];

Future<void> retrieveTrips(
    double fromLong, double fromLat, List<Walk> walks) async {
  String coordinates = "$fromLong,$fromLat";
  for (int i = 0; i < min(walks.length, 24); i++) {
    Walk walk = walks[i];
    if (walk.isPositionable()) {
      coordinates = coordinates + ";${walk.long},${walk.lat}";
    }
  }
  final String url =
      "https://api.mapbox.com/directions-matrix/v1/mapbox/driving/$coordinates?sources=0&annotations=distance,duration&access_token=$_token";
  final http.Response response = await http.get(url);
  final decoded = json.decode(response.body);
  final distances =
      decoded['distances']?.length == 1 ? decoded['distances'][0] : null;
  final durations =
      decoded['durations']?.length == 1 ? decoded['durations'][0] : null;
  if (distances != null && durations != null) {
    for (int i = 0; i < min(walks.length, 24); i++) {
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
    bool interactive = true}) {
  return FlutterMap(
    options: new MapOptions(
        center: LatLng(centerLat, centerLong),
        zoom: zoom,
        interactive: interactive),
    layers: [
      new TileLayerOptions(
        urlTemplate: "https://api.tiles.mapbox.com/v4/"
            "{id}/{z}/{x}/{y}@2x.png?access_token={accessToken}",
        additionalOptions: {
          'accessToken': _token,
          'id':
              brightness == Brightness.dark ? 'mapbox.dark' : 'mapbox.streets',
        },
      ),
      new MarkerLayerOptions(markers: markers),
    ],
  );
}

Future<List<MapBoxSuggestion>> retrieveSuggestions(String search) async {
  if (search.isNotEmpty) {
    final String url =
        "https://api.mapbox.com/geocoding/v5/mapbox.places/$search.json?access_token=$_token&country=BE&language=fr_BE&limit=10&types=address";
    final http.Response response = await http.get(url);
    var decoded = json.decode(response.body);
    List<MapBoxSuggestion> results = List<MapBoxSuggestion>();
    if (decoded['features'] != null) {
      for (var result in decoded['features']) {
        results.add(MapBoxSuggestion(
            address: result['place_name'],
            longitude: result['center'][0],
            latitude: result['center'][1]));
      }
    }
    return results;
  } else {
    return List<MapBoxSuggestion>();
  }
}

Future<String> retrieveAddress(double long, double lat) async {
  final String url =
      "https://api.mapbox.com/geocoding/v5/mapbox.places/$long,$lat.json?access_token=$_token";
  final http.Response response = await http.get(url);
  var decoded = json.decode(response.body);
  if (decoded['features'].length > 0) {
    return decoded['features'][0]['place_name'];
  } else {
    return null;
  }
}
