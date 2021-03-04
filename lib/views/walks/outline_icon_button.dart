import 'package:flutter/material.dart';

class OutlineIconButton extends StatelessWidget {
  OutlineIconButton({this.onPressed, this.iconData});

  @required
  final VoidCallback onPressed;
  @required
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 50.0,
        child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
                padding: EdgeInsets.all(0.0),
                primary: Theme.of(context).textTheme.bodyText1.color),
            child: Icon(iconData)));
  }
}
