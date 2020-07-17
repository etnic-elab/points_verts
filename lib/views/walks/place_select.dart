import 'package:flutter/material.dart';
import 'walks_view.dart';

class PlaceSelect extends StatelessWidget {
  PlaceSelect({this.currentPlace, this.onChanged});

  final Places currentPlace;
  final ValueChanged<Places> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Places>(
      value: currentPlace,
      onChanged: onChanged,
      items: [
        DropdownMenuItem(child: Text("Du domicile"), value: Places.home),
        DropdownMenuItem(child: Text("De la position"), value: Places.current),
      ],
    );
  }
}
