import 'package:flutter/material.dart';
import 'package:points_verts/asset.dart';
import 'package:points_verts/models/walk.dart';

class WalkIcon extends StatelessWidget {
  const WalkIcon(this.walk, {this.size, Key? key}) : super(key: key);

  final Walk walk;
  final double? size;

  @override
  Widget build(BuildContext context) {
    if (walk.isCancelled()) {
      return Image(
          image: Assets.assetImage(Assets.logoAnnule, context),
          height: size ?? 30,
          semanticLabel: "Point annulé");
    } else if (walk.type == 'Marche' || walk.type == 'Orientation') {
      return Image(
          image: Assets.assetImage(Assets.logo, context),
          height: size ?? 30,
          semanticLabel: "Marche/Orientation");
    } else {
      return const SizedBox.shrink();
    }
  }
}
