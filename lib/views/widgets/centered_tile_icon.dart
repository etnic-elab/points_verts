import 'package:flutter/widgets.dart';

class CenteredTileWidget extends StatelessWidget {
  const CenteredTileWidget(this.widget, {Key? key}) : super(key: key);

  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: double.infinity, child: widget);
  }
}
