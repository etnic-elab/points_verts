import 'package:flutter/material.dart';

class ListHeader extends StatelessWidget {
  const ListHeader(this.title, {Key? key}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(title,
          style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 15.0)),
      padding: const EdgeInsets.all(15.0),
    );
  }
}
