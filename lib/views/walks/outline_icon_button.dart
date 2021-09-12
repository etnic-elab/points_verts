import 'package:flutter/material.dart';

class OutlineIconButton extends StatelessWidget {
  const OutlineIconButton({this.onPressed, this.iconData, Key? key})
      : super(key: key);

  @required
  final VoidCallback? onPressed;
  @required
  final IconData? iconData;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 50.0,
        child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(0.0),
                primary: Theme.of(context).textTheme.bodyText1!.color),
            child: Icon(iconData)));
  }
}
