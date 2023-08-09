import 'package:flutter/material.dart';

class OutlineIconButton extends StatelessWidget {
  const OutlineIconButton(
      {this.onPressed, this.iconData, this.semanticLabel, Key? key})
      : super(key: key);

  @required
  final VoidCallback? onPressed;
  @required
  final IconData? iconData;
  @required
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return IconButton.outlined(
        onPressed: onPressed,
        icon: Icon(
          iconData,
          semanticLabel: semanticLabel,
        ));
  }
}
