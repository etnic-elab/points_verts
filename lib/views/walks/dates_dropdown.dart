import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatesDropdown extends StatelessWidget {
  DatesDropdown({this.dates, this.selectedDate, this.onChanged});

  final Future<List<DateTime>> dates;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    DateFormat fullDate = DateFormat.yMMMEd("fr_BE");
    return FutureBuilder<List<DateTime>>(
        future: dates,
        builder:
            (BuildContext context, AsyncSnapshot<List<DateTime>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data.isNotEmpty) {
              List<DateTime> dates = snapshot.data;
              return ActionChip(
                  onPressed: () async {
                    DateTime pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        selectableDayPredicate: (date) => dates.contains(date),
                        fieldLabelText: "Choix de la date",
                        helpText: "Choix de la date",
                        fieldHintText: "dd/mm/aaaa",
                        errorInvalidText: "Pas de marche à la date choisie.",
                        errorFormatText: "Format invalide.",
                        firstDate: dates.first,
                        lastDate: dates.last);
                    if (pickedDate != null) {
                      onChanged(pickedDate);
                    }
                  },
                  label: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.calendar_today, size: 16.0),
                      ),
                      Text(fullDate.format(selectedDate))
                    ],
                  ));
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
