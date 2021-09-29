import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../models/address_suggestion.dart';

import '../../models/walk.dart';

abstract class MapInterface {
  String? _token;

  Future<void> retrieveTrips(double fromLong, double fromLat, List<Walk> walks);

  Widget retrieveMap(List<Marker> markers, Brightness brightness,
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
