import 'package:flutter/material.dart';
import 'package:points_verts/services/assets.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class LoadingText extends StatelessWidget {
  const LoadingText(this.text, {Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Loading(),
        Container(padding: const EdgeInsets.all(10), child: Text(text))
      ],
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Spacer(flex: 1),
          Image(
              image:
                  Assets.asset.image(Theme.of(context).brightness, Assets.logo),
              height: MediaQuery.of(context).size.longestSide * 0.1),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32.0),
            child: CircularProgressIndicator(),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
