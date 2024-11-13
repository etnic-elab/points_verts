import 'package:json_map_typedef/json_map_typedef.dart';
import 'package:maps_api/maps_api.dart' show DistanceCalculator;
import 'package:trail_parser_api/trail_parser_api.dart' show TrailPoint;

class TrailInfo {
  const TrailInfo({
    required this.points,
  });

  factory TrailInfo.fromJson(JsonMap json) {
    return TrailInfo(
      points: (json['points'] as List<dynamic>)
          .map((point) => TrailPoint.fromJson(point as JsonMap))
          .toList(),
    );
  }

  final List<TrailPoint> points;

  double get totalDistance {
    var distance = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      distance += DistanceCalculator.haversine(
        points[i].location,
        points[i + 1].location,
      );
    }
    return distance;
  }

  double get elevationGain {
    var gain = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      final diff = (points[i + 1].elevation ?? 0) - (points[i].elevation ?? 0);
      if (diff > 0) gain += diff;
    }
    return gain;
  }

  double get elevationLoss {
    var loss = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      final diff = (points[i + 1].elevation ?? 0) - (points[i].elevation ?? 0);
      if (diff < 0) loss += diff.abs();
    }
    return loss;
  }

  JsonMap toJson() {
    return {
      'points': points.map((point) => point.toJson()).toList(),
    };
  }
}
