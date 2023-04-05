import 'package:flutter/material.dart';

class ListHeader extends StatelessWidget {
  const ListHeader(this.title, {Key? key, this.padding}) : super(key: key);

  final String title;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Container(
        padding: padding ??
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(title,
            style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 15.0)),
      ),
    );
  }
}
