import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'walk_date.dart';

class DatesDropdown extends StatelessWidget {
  DatesDropdown({this.dates, this.selectedDate, this.onChanged});

  final Future<List<WalkDate>> dates;
  final WalkDate selectedDate;
  final ValueChanged<WalkDate> onChanged;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WalkDate>>(
        future: dates,
        builder:
            (BuildContext context, AsyncSnapshot<List<WalkDate>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return DropdownButton(
                  value: selectedDate,
                  items: generateDropdownItems(snapshot.data),
                  onChanged: onChanged);
            } else {
              return SizedBox.shrink();
            }
          } else {
            return SizedBox.shrink();
          }
        });
  }

  static List<DropdownMenuItem<WalkDate>> generateDropdownItems(
      List<WalkDate> dates) {
    DateFormat fullDate = DateFormat.yMMMEd("fr_BE");
    return dates.map((WalkDate walkDate) {
      return DropdownMenuItem<WalkDate>(
          value: walkDate, child: new Text(fullDate.format(walkDate.date)));
    }).toList();
  }
}
