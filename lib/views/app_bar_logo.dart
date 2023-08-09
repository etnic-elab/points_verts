import 'package:flutter/material.dart';

import '../services/assets.dart';

class AppBarLogo extends StatelessWidget {
  const AppBarLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Image(
        image: Assets.asset.image(Theme.of(context).brightness, Assets.logo),
      ),
    );
  }
}