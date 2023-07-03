import 'package:flutter/material.dart';
import 'package:points_verts/services/assets.dart';
import 'package:points_verts/models/walk.dart';

class WalkIcon extends StatelessWidget {
  const WalkIcon(this.walk, {this.size, Key? key}) : super(key: key);

  final Walk walk;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    if (walk.isCancelled) {
      return Image(
        image: Assets.asset.image(brightness, Assets.logoAnnule),
        height: size ?? 30,
        semanticLabel: "Annulé",
      );
    } else if (walk.type == 'Marche' || walk.type == 'Orientation') {
      return Image(
        image: Assets.asset.image(brightness, Assets.logo),
        height: size ?? 30,
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
