import 'package:points_verts/walk_details.dart';
import 'package:points_verts/services/openweather/weather.dart';

import 'services/mapbox/trip.dart';

class Walk {
  Walk(
      {this.id,
      this.city,
      this.type,
      this.province,
      this.long,
      this.lat,
      this.date,
      this.status});

  final int id;
  final String city;
  final String type;
  final String province;
  final String date;
  final double long;
  final double lat;
  final String status;

  double distance;
  Trip trip;
  Future<WalkDetails> details;
  Future<List<Weather>> weathers;

  bool isCancelled() {
    return status == "ptvert_annule";
  }

  String getFormattedDistance() {
    double dist =
        trip != null && trip.distance != null ? trip.distance : distance;
    if (dist == null) {
      return null;
    } else if (dist < 1000) {
      return '${dist.round().toString()} m';
    } else {
      return '${(dist / 1000).round().toString()} km';
    }
  }

  bool isPositionable() {
    return long != null && lat != null && !isCancelled();
  }
}
