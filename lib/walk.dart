import 'package:flutter/foundation.dart';

class Walk {
  Walk({@required this.city, this.province, this.long, this.lat, this.date});

  final String city;
  final String province;
  final String date;
  final double long;
  final double lat;

  double distance;
}
