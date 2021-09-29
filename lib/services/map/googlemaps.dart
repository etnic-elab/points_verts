import 'package:points_verts/models/walk.dart';
import 'package:points_verts/models/address_suggestion.dart';
import 'package:flutter_map/src/layer/marker_layer.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'dart:ui';

import 'package:points_verts/services/map/map_interface.dart';

class GoogleMaps implements MapInterface {
  @override
  Future<String?> retrieveAddress(double long, double lat) {
    // TODO: implement retrieveAddress
    throw UnimplementedError();
  }

  @override
  Widget retrieveMap(List<Marker> markers, Brightness brightness,
      {double centerLat = 50.3155646,
      double centerLong = 5.009682,
      double zoom = 7.5,
      interactive = InteractiveFlag.all}) {
    // TODO: implement retrieveMap
    throw UnimplementedError();
  }

  @override
  Widget retrieveStaticImage(
      double? long, double? lat, int width, int height, Brightness brightness,
      {double zoom = 16.0}) {
    // TODO: implement retrieveStaticImage
    throw UnimplementedError();
  }

  @override
  Future<List<AddressSuggestion>> retrieveSuggestions(
      String country, String search) {
    // TODO: implement retrieveSuggestions
    throw UnimplementedError();
  }

  @override
  Future<void> retrieveTrips(
      double fromLong, double fromLat, List<Walk> walks) {
    // TODO: implement retrieveTrips
    throw UnimplementedError();
  }
}
