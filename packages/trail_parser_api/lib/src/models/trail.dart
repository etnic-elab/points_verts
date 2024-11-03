import 'package:maps_api/maps_api.dart' show DistanceCalculator;
import 'package:trail_parser_api/trail_parser_api.dart' show TrailPoint;

class Trail {
  const Trail({
    required this.points,
  });

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
}
