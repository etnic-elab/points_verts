import 'package:flutter/material.dart';
import 'package:points_verts/models/walk.dart';
import 'package:points_verts/models/walk_filter.dart';

class RouteRange {
  static IconData icon = Icons.route;
  static label(Walk walk, {bool compact = false}) {
    if (walk.isWalk) {
      return walk.fifteenKm
          ? compact
              ? "5-10-15-20 km"
              : 'Parcours de 5 - 10 - 15 - 20 km'
          : compact
              ? '5-10-20 km'
              : 'Parcours de 5 - 10 - 20 km';
    } else if (walk.isOrientation) {
      return compact ? "4-8-16 km" : "Parcours de 4 - 8 - 16 km";
    }

    return '';
  }
}

enum WalkInfo {
  fifteenKm,
  transport,
  wheelchair,
  stroller,
  extraOrientation,
  extraWalk,
  guided,
  bike,
  mountainBike,
  waterSupply,
  beWapp,
  adepSante,
}

extension WalkInfoExt on WalkInfo {
  IconData get icon {
    switch (this) {
      case WalkInfo.fifteenKm:
        return Icons.directions_walk;
      case WalkInfo.transport:
        return Icons.train;
      case WalkInfo.wheelchair:
        return Icons.accessible_forward;
      case WalkInfo.stroller:
        return Icons.child_friendly;
      case WalkInfo.extraOrientation:
        return Icons.map;
      case WalkInfo.extraWalk:
        return Icons.directions_walk;
      case WalkInfo.guided:
        return Icons.nature_people;
      case WalkInfo.bike:
        return Icons.directions_bike;
      case WalkInfo.mountainBike:
        return Icons.directions_bike;
      case WalkInfo.waterSupply:
        return Icons.water_drop;
      case WalkInfo.beWapp:
        return Icons.eco;
      case WalkInfo.adepSante:
        return Icons.sports_gymnastics;
    }
  }

  String get label {
    switch (this) {
      case WalkInfo.fifteenKm:
        return 'Parcours 15 km';
      case WalkInfo.transport:
        return 'Train/Bus';
      case WalkInfo.wheelchair:
        return 'PMR';
      case WalkInfo.stroller:
        return 'Poussettes';
      case WalkInfo.extraOrientation:
        return '+ Orientation';
      case WalkInfo.extraWalk:
        return '+ Marche';
      case WalkInfo.guided:
        return 'Balade guidée';
      case WalkInfo.bike:
        return 'Vélo';
      case WalkInfo.mountainBike:
        return 'VTT';
      case WalkInfo.waterSupply:
        return 'Ravitaillement';
      case WalkInfo.beWapp:
        return 'BeWaPP';
      case WalkInfo.adepSante:
        return 'Adep\'santé';
    }
  }

  String get description {
    switch (this) {
      case WalkInfo.fifteenKm:
        return 'Parcours supplémentaire de marche de 15km';
      case WalkInfo.transport:
        return 'Accessible en transports en commun';
      case WalkInfo.wheelchair:
        return 'Parcours de 5 km accessible aux PMR';
      case WalkInfo.stroller:
        return 'Parcours de 5 km accessible aux landaus';
      case WalkInfo.extraOrientation:
        return 'Parcours supplémentaire d\'orientation de +/- 8km';
      case WalkInfo.extraWalk:
        return 'Parcours supplémentaire de marche de +/- 10km';
      case WalkInfo.guided:
        return 'Balade guidée Nature';
      case WalkInfo.bike:
        return 'Parcours supplémentaire de vélo de +/- 20 km';
      case WalkInfo.mountainBike:
        return 'Parcours supplémentaire de VTT de +/- 20 km';
      case WalkInfo.waterSupply:
        return 'Ravitaillement';
      case WalkInfo.beWapp:
        return 'Participe à "Wallonie Plus Propre"';
      case WalkInfo.adepSante:
        return 'Possibilité de réaliser de petits exercices sur le parcours de 5 km';
    }
  }

  String? get url {
    switch (this) {
      case WalkInfo.beWapp:
        return 'https://www.walloniepluspropre.be/';
      default:
        return null;
    }
  }

  bool walkValue(Walk walk) {
    switch (this) {
      case WalkInfo.fifteenKm:
        return walk.fifteenKm;
      case WalkInfo.transport:
        return walk.transport?.isNotEmpty ?? false;
      case WalkInfo.wheelchair:
        return walk.wheelchair;
      case WalkInfo.stroller:
        return walk.stroller;
      case WalkInfo.extraOrientation:
        return walk.extraOrientation;
      case WalkInfo.extraWalk:
        return walk.extraWalk;
      case WalkInfo.guided:
        return walk.guided;
      case WalkInfo.bike:
        return walk.bike;
      case WalkInfo.mountainBike:
        return walk.mountainBike;
      case WalkInfo.waterSupply:
        return walk.waterSupply;
      case WalkInfo.beWapp:
        return walk.beWapp;
      case WalkInfo.adepSante:
        return walk.adepSante;
    }
  }

  bool filterValue(WalkFilter filter) {
    switch (this) {
      case WalkInfo.fifteenKm:
        return filter.fifteenKm;
      case WalkInfo.transport:
        return filter.transport;
      case WalkInfo.wheelchair:
        return filter.wheelchair;
      case WalkInfo.stroller:
        return filter.stroller;
      case WalkInfo.extraOrientation:
        return filter.extraOrientation;
      case WalkInfo.extraWalk:
        return filter.extraWalk;
      case WalkInfo.guided:
        return filter.guided;
      case WalkInfo.bike:
        return filter.bike;
      case WalkInfo.mountainBike:
        return filter.mountainBike;
      case WalkInfo.waterSupply:
        return filter.waterSupply;
      case WalkInfo.beWapp:
        return filter.beWapp;
      case WalkInfo.adepSante:
        return filter.adepSante;
    }
  }
}
