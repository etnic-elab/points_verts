import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_api/maps_api.dart';
import 'package:points_verts/models/walk.dart';
import 'package:points_verts/views/maps/interactive_map.dart';
import 'package:points_verts/views/maps/markers/marker_interface.dart';
import 'package:points_verts/views/maps/markers/walk_marker.dart';
import 'package:collection/collection.dart';

import 'dart:io' show Platform;

class WalkDetailsMapView extends StatelessWidget {
  const WalkDetailsMapView(
    this.walk,
    this.onTapMap,
    this.location, {
    super.key,
  });

  final Walk walk;
  final Function onTapMap;
  final Function location;

  List<MarkerInterface> get _markers {
    if (walk.hasPosition) {
      return [WalkMarker(walk)];
    }

    return [];
  }

  Geolocation? get center {
    if (walk.lat != null && walk.long != null) {
      return Geolocation(latitude: walk.lat!, longitude: walk.long!);
    }

    final firstPath = walk.paths.firstOrNull;
    final firstPoint = firstPath?.gpxPoints.firstOrNull;

    if (firstPoint != null) {
      return Geolocation(
        latitude: firstPoint.latLng.latitude,
        longitude: firstPoint.latLng.longitude,
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final interactiveMap = InteractiveMap();
    return FutureBuilder<LocationPermission>(
      future: location(),
      builder:
          (BuildContext context, AsyncSnapshot<LocationPermission> snapshot) {
        if (snapshot.hasData) {
          return Platform.isIOS
              ? Semantics(
                  label: 'La carte visualisant les parcours',
                  excludeSemantics: true,
                  child: interactiveMap.getMap(
                    center: center,
                    zoom: 11.5,
                    locationEnabled: true,
                    markers: _markers,
                    paths: walk.paths,
                    onTapMap: onTapMap,
                  ),
                )
              : interactiveMap.getMap(
                  center: center,
                  zoom: 11.5,
                  locationEnabled: true,
                  markers: _markers,
                  paths: walk.paths,
                  onTapMap: onTapMap,
                );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
