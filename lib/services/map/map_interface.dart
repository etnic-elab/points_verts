import 'package:flutter/material.dart';
import 'package:points_verts/services/map/markers/marker_interface.dart';

import '../../models/address_suggestion.dart';

import '../../models/walk.dart';

abstract class MapInterface {
  Future<void> retrieveTrips(double fromLong, double fromLat, List<Walk> walks);

  /// Returns a Widget with a map displaying the markers
  /// and a zoom on a specific location (lat/lng)
  ///
  /// @param markers The markers to add
  /// @param brightness The brightness of the application/map.
  /// @param centerLat The center latitude of the map.
  /// @param centerLong The center longitude of the map.
  /// @param zoom The zoom on the application/map.
  /// @returns A Widget that contains the map.
  /// @throws ArgumentError If there is already an option with
  ///     the given name or abbreviation.
  Widget retrieveMap(List<MarkerInterface> markers, Function onMapTap,
      {double centerLat = 50.3155646,
      double centerLong = 5.009682,
      double zoom = 7.5});

  Future<List<AddressSuggestion>> retrieveSuggestions(
      String country, String search);

  Future<String?> retrieveAddress(double long, double lat);

  Widget retrieveStaticImage(
      Walk walk, int width, int height, Brightness brightness,
      {double zoom = 16.0});
}
