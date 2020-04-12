import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatesDropdown extends StatelessWidget {
  DatesDropdown({this.dates, this.selectedDate, this.onChanged});

  final Future<List<DateTime>> dates;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DateTime>>(
        future: dates,
        builder:
            (BuildContext context, AsyncSnapshot<List<DateTime>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data.isNotEmpty) {
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

  static List<DropdownMenuItem<DateTime>> generateDropdownItems(
      List<DateTime> dates) {
    DateFormat fullDate = DateFormat.yMMMEd("fr_BE");
    return dates.map((DateTime walkDate) {
      return DropdownMenuItem<DateTime>(
          value: walkDate, child: new Text(fullDate.format(walkDate)));
    }).toList();
  }
}
