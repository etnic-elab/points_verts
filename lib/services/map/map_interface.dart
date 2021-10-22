import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../models/address_suggestion.dart';

import '../../models/walk.dart';

abstract class MapInterface {
  Future<void> retrieveTrips(double fromLong, double fromLat, List<Walk> walks);

  /// Returns a Widget with a map displaying the markers
  /// and a zoom on a specific location (lat/lng)
  ///
  /// @param markers The markers to add
  /// (flutter_map/Marker, used to display the markers in FlutterMap).
  /// @param rawMarkers The raw markers to add
  /// (core/Map, used to custom build markers).
  /// @param brightness The brightness of the application/map.
  /// @param centerLat The center latitude of the map.
  /// @param centerLong The center longitude of the map.
  /// @param zoom The zoom on the application/map.
  /// @param interactive The interaction available with the map.
  /// @returns A Widget that contains the map.
  /// @throws ArgumentError If there is already an option with
  ///     the given name or abbreviation.
  Widget retrieveMap(
      List<Marker> markers, List<Map> rawMarkers, Brightness brightness,
      {double centerLat = 50.3155646,
      double centerLong = 5.009682,
      double zoom = 7.5,
      interactive = InteractiveFlag.all});

  Future<List<AddressSuggestion>> retrieveSuggestions(
      String country, String search);

  Future<String?> retrieveAddress(double long, double lat);

  Widget retrieveStaticImage(
      double? long, double? lat, int width, int height, Brightness brightness,
      {double zoom = 16.0});
}
