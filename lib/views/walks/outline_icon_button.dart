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
    return SizedBox(
        width: 50.0,
        child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
                elevation: 4.0,
                padding: const EdgeInsets.all(8.0),
                foregroundColor: Theme.of(context).textTheme.bodyText1!.color),
            child: Icon(
              iconData,
              semanticLabel: semanticLabel,
              size: 30.0,
            )));
  }
}
