import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'trip.dart';
import 'walk_utils.dart';

class Walk {
  Walk(
      {this.city,
      this.type,
      this.province,
      this.long,
      this.lat,
      this.date,
      this.status});

  final String city;
  final String type;
  final String province;
  final String date;
  final double long;
  final double lat;
  final String status;

  double distance;
  Trip trip;

  bool isCancelled() {
    return status == "ptvert_annule";
  }

  String getFormattedDistance() {
    double dist = trip != null && trip.distance != null ? trip.distance : distance;
    if (dist == null) {
      return null;
    } else if (dist < 1000) {
      return '${dist.round().toString()} m';
    } else {
      return '${(dist / 1000).round().toString()} km';
    }
  }
}
