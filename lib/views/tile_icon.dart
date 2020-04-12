import 'package:flutter/cupertino.dart';

class TileIcon extends StatelessWidget {
  TileIcon(this.icon);

  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[icon]);
  }
}
