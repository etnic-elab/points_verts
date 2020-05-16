import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ListHeader extends StatelessWidget {
  ListHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(title, style: Theme.of(context).textTheme.headline6),
      padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 5.0),
    );
  }
}
