import 'package:flutter/widgets.dart';

class TileIcon extends StatelessWidget {
  const TileIcon(this.icon, {super.key});

  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[icon],);
  }
}
