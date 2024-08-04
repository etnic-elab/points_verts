import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:points_verts/models/path.dart';
import 'package:points_verts/services/map/azure_maps.dart';
import 'package:points_verts/services/map/googlemaps.dart';
import 'package:points_verts/services/map/mapbox.dart';
import 'package:points_verts/services/map/markers/marker_interface.dart';

import '../../models/address.dart';

import '../../models/walk.dart';

enum Maps { google, mapbox, azure }

extension MapsX on Maps {
  MapInterface get instance {
    switch (this) {
      case Maps.google:
        return GoogleMaps();
      case Maps.mapbox:
        return MapBox();
      case Maps.azure:
        return AzureMaps();
    }
  }
}

abstract class MapInterface {
  static const double defaultLat = 50.3155646;
  static const double defaultLong = 4.6;
  static const double defaultZoom = 7.35;

  String get name;
  String get apiName;
  String get website;

  String? get apiKey => dotenv.env[apiName];

  Future<void> retrieveTrips(double fromLong, double fromLat, List<Walk> walks);

  Future<List<AddressSuggestion>> retrieveSuggestions(
      String search, String country,
      {String? sessionToken});

  Future<Address?> retrievePlaceDetailFromId(String placeId,
      {String? sessionToken});

  /// Returns a Widget with a map displaying the markers
  /// and a zoom on a specific location (lat/lng)
  ///
  /// @param markers The markers to add
  /// @param centerLat The center latitude of the map.
  /// @param centerLong The center longitude of the map.
  /// @param zoom The zoom on the application/map.
  /// @returns A Widget that contains the map.
  /// @throws ArgumentError If there is already an option with
  ///     the given name or abbreviation.
  Widget retrieveMap({
    double centerLat,
    double centerLong,
    double zoom,
    locationEnabled,
    List<MarkerInterface> markers,
    List<Path> paths,
    Function? onTapMap,
    Function(Path)? onTapPath,
  });

  Widget retrieveStaticImage(
      Walk walk, int width, int height, Brightness brightness,
      {double zoom, Function? onTap});
}
