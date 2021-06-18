import 'package:flutter/material.dart';
import 'package:points_verts/models/walk.dart';

class WalkIcon extends StatelessWidget {
  WalkIcon(this.walk, {this.size});

  final Walk walk;
  final double? size;

  @override
  Widget build(BuildContext context) {
    if (walk.isCancelled()) {
      return Image(
          image: AssetImage('assets/logo-annule.png'),
          height: size ?? 30,
          semanticLabel: "Point annulé");
    } else if (walk.type == 'Marche' || walk.type == 'Orientation') {
      return Image(
          image: AssetImage('assets/logo.png'),
          height: size ?? 30,
          semanticLabel: "Marche/Orientation");
    } else {
      return SizedBox.shrink();
    }
  }
}
