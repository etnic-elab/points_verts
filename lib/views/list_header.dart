import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ListHeader extends StatelessWidget {
  ListHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(title,
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
      padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
    );
  }
}
