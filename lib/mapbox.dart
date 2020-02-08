import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'mapbox_suggestion.dart';
import 'trip.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String _token =
    'pk.eyJ1IjoidGJvcmxlZSIsImEiOiJjazRvNGI4ZXAycTBtM2txd2Z3eHk3Ymh1In0.12yn8XMdhqdoPByYti4g5g';

Future<Trip> retrieveTrip(
    double fromLong, double fromLat, double toLong, double toLat) async {
  final String url =
      'https://api.mapbox.com/optimized-trips/v1/mapbox/driving/$fromLong,$fromLat;$toLong,$toLat?roundtrip=false&source=first&destination=last&access_token=$_token';
  final http.Response response = await http.get(url);
  var decoded = json.decode(response.body);
  if (decoded['trips'] != null && decoded['trips'].length > 0) {
    return Trip(
        distance: decoded['trips'][0]['distance'].toDouble(),
        duration: decoded['trips'][0]['duration'].toDouble());
  } else {
    return null;
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
        results.add(MapBoxSuggestion(address: result['place_name'], longitude: result['center'][0], latitude: result['center'][1]));
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
