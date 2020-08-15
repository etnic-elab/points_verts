import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ListHeader extends StatelessWidget {
  ListHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(title,
          style: TextStyle(
              color: Theme.of(context).accentColor,
              fontWeight: FontWeight.bold)),
      padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
    );
  }
}
