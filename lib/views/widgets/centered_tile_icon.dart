import 'package:flutter/widgets.dart';

class CenteredTileWidget extends StatelessWidget {
  const CenteredTileWidget({required this.child, Key? key}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[child]);
  }
}
