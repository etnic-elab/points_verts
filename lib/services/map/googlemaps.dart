import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:points_verts/services/map/map_interface.dart';

import '../../models/address_suggestion.dart';
import '../../models/trip.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../models/walk.dart';

class GoogleMaps implements MapInterface {
  String? _apiKey = dotenv.env['GOOGLEMAPS_API_KEY'];

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
          //urlTemplate: "https://mt{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}&key=$_apiKey",
          //urlTemplate: "https://maps.googleapis.com/maps/api/staticmap?key=$_apiKey&zoom={z}&format=png&center={x},{y}",
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          tileSize: 512,
          maxZoom: 18,
          zoomOffset: -1,
          //subdomains: ['0', '1', '2', '3'],
          subdomains: ['a', 'b', 'c'],
          additionalOptions: {
            'id': brightness == Brightness.dark ? 'dark-v10' : 'light-v10',
          },
        ),
        new MarkerLayerOptions(markers: markers),
      ],
    );
  }

  @override
  Widget retrieveStaticImage(
      double? long, double? lat, int width, int height, Brightness brightness,
      {double zoom = 16.0}) {
    {
      var body = {
        "size": "${width}x$height",
        "center": "$lat,$long",
        "markers": "color:blue|$lat,$long",
        "zoom": "13",
        "key": _apiKey
      };
      Uri url = Uri.https("maps.googleapis.com", "/maps/api/staticmap", body);

      return CachedNetworkImage(
        imageUrl: url.toString(),
        progressIndicatorBuilder: (context, url, downloadProgress) => Center(
            child: CircularProgressIndicator(value: downloadProgress.progress)),
        errorWidget: (context, url, error) => Icon(Icons.error),
      );
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
      if (decoded['results'] != null && decoded['results'].length > 0) {
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
  Future<void> retrieveTrips(
      double fromLong, double fromLat, List<Walk> walks) async {
    String origin = "$fromLat,$fromLong";
    List<String> destinationsList = [];
    http.Response response;

    // loop on each walk to get the lat/long
    walks.forEach((walk) {
      destinationsList.add("$walk.lat,$walk.long");
    });

    String destinations = destinationsList.join("|");

    var body = {
      "origins": origin,
      "destinations": destinations,
      "key": _apiKey
    };

    Uri url =
        Uri.https("maps.googleapis.com", "/maps/api/distancematrix/json", body);

    response = await http.get(url);

    var result = json.decode(response.body);

    for (int i = 0; i < min(walks.length, 5); i++) {
      var walkElement = result["rows"][0]["elements"][i];
      Walk walk = walks[i];
      walk.trip = Trip(
          distance: walkElement["distance"]["value"],
          duration: walkElement["duration"]["value"]);
    } // update the trip distance/duration for each walk
  }
}
