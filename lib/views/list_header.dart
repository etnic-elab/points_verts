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
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
    );
  }
}
