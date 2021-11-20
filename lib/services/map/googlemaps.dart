import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:points_verts/company_data.dart';
import 'package:points_verts/environment.dart';
import 'package:points_verts/services/assets.dart';
import 'package:points_verts/services/map/map_interface.dart';
import 'package:points_verts/services/map/markers/marker_generator.dart';
import 'package:points_verts/services/map/markers/marker_interface.dart';
import 'package:points_verts/views/loading.dart';
import 'package:points_verts/views/walks/walks_view.dart';

import '../../models/address_suggestion.dart';
import '../../models/trip.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../models/walk.dart';
import '../cache_managers/trip_cache_manager.dart';

enum GoogleMapIcons {
  unselectedWalkIcon,
  unselectedCancelIcon,
  selectedWalkIcon,
  selectedCancelIcon
}

extension GoogleMapIconsExtension on GoogleMapIcons {
  String get logo {
    switch (this) {
      case GoogleMapIcons.unselectedWalkIcon:
      case GoogleMapIcons.selectedWalkIcon:
        return Assets.logo;
      case GoogleMapIcons.unselectedCancelIcon:
      case GoogleMapIcons.selectedCancelIcon:
        return Assets.logoAnnule;
    }
  }

  Color get color {
    switch (this) {
      case GoogleMapIcons.unselectedWalkIcon:
      case GoogleMapIcons.unselectedCancelIcon:
        return CompanyColors.darkGreen;
      case GoogleMapIcons.selectedWalkIcon:
      case GoogleMapIcons.selectedCancelIcon:
        return CompanyColors.lightestGreen;
    }
  }
}

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
  Widget retrieveMap(
      List<MarkerInterface> markers, Brightness brightness, Function onMapTap,
      {double centerLat = 50.3155646,
      double centerLong = 5.009682,
      double zoom = 7.5}) {
    final Completer<GoogleMapController> _controller = Completer();
    //The angle, in degrees, of the camera angle from the nadir.
    const double cameraTilt = 0;
    // The camera's bearing in degrees, measured clockwise from north
    const double cameraBearing = 0;
    return FutureBuilder(
        future: _createMapIcons(brightness),
        builder: (BuildContext context,
            AsyncSnapshot<Map<dynamic, BitmapDescriptor>> snapshot) {
          if (snapshot.hasData) {
            final Set<Marker> _googleMarkers = <Marker>{};
            for (MarkerInterface marker in markers) {
              _googleMarkers.add(marker.buildGoogleMarker(snapshot.data!));
            }

            return GoogleMap(
                mapType: MapType
                    .normal, // none, normal, hybrid, satellite and terrain
                initialCameraPosition: CameraPosition(
                    target: LatLng(centerLat, centerLong),
                    zoom: zoom,
                    tilt: cameraTilt,
                    bearing: cameraBearing),
                onMapCreated: (GoogleMapController controller) async {
                  if (brightness == Brightness.dark) {
                    final String style = await Assets.instance
                        .assetJson(Assets.googlemapDarkJsonPath);
                    controller.setMapStyle(style);
                  }
                  _controller.complete(controller);
                },
                onTap: (LatLng _) {
                  onMapTap();
                },
                markers: _googleMarkers);
          }
          return const Loading();
        });
  }

  Future<Map<dynamic, BitmapDescriptor>> _createMapIcons(
      Brightness brightness) async {
    final Map<dynamic, BitmapDescriptor> mapIcons =
        <dynamic, BitmapDescriptor>{};
    MarkerGenerator markerGenerator = MarkerGenerator(70);

    for (var value in GoogleMapIcons.values) {
      final byteData =
          await Assets.instance.assetByteData(value.logo, brightness);
      final BitmapDescriptor image =
          await markerGenerator.createBitmapDescriptorFromByteData(
              byteData, value.color, value.color);
      mapIcons[value] = image;
    }

    for (var value in Places.values) {
      Color color =
          brightness == Brightness.light ? Colors.black : Colors.white;
      final BitmapDescriptor image = await markerGenerator
          .createBitmapDescriptorFromIconData(value.icon, color);
      mapIcons[value] = image;
    }

    return mapIcons;
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
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    }
  }
}
