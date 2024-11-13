import 'package:flutter/material.dart';

import '../services/assets.dart';

class AppBarLogo extends StatelessWidget {
  const AppBarLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Image(
        height: 30,
        image: Assets.asset.image(Theme.of(context).brightness, Assets.logo),
        semanticLabel: 'Logo Points Verts',
      ),
    );
  }
}