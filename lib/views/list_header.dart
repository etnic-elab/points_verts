import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ListHeader extends StatelessWidget {
  ListHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Center(
          child:
              Text(title, style: Theme.of(context).primaryTextTheme.subtitle)),
      padding: EdgeInsets.all(10.0),
    );
  }
}
