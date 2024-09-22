import 'dart:ui';

class MapPath {
  MapPath({
    required this.points,
    required this.color,
    this.weight,
  }) : assert(points.isNotEmpty, 'points list cannot be empty');

  final List<List<num>> points;
  final Color color;
  final int? weight;
}
