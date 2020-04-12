import 'package:flutter/widgets.dart';

class TileIcon extends StatelessWidget {
  TileIcon(this.icon);

  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[icon]);
  }
}
