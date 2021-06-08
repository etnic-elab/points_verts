import 'package:flutter/material.dart';
import 'package:points_verts/models/walk.dart';

class WalkIcon extends StatelessWidget {
  WalkIcon(this.walk, {this.color, this.size});

  final Walk walk;
  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    if (walk.isCancelled()) {
      return Icon(Icons.cancel,
          color: color, size: size, semanticLabel: "Point annulé");
    } else if (walk.type == 'Marche') {
      return Icon(Icons.directions_walk,
          color: color, size: size, semanticLabel: "Marche");
    } else if (walk.type == 'Orientation') {
      return Icon(Icons.map,
          color: color, size: size, semanticLabel: "Orientation");
    } else {
      return SizedBox.shrink();
    }
  }
}
