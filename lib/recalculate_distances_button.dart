import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RecalculateDistancesButton extends StatelessWidget {
  RecalculateDistancesButton({this.onPressed});

  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: "Recalculer ma position actuelle",
        icon: Icon(Icons.my_location),
        onPressed: () {
          onPressed();
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Recalcul des distances selon la position actuelle.'),
            ),
          );
        });
  }
}
