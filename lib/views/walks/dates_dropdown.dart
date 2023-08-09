import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatesDropdown extends StatelessWidget {
  const DatesDropdown(
      {required this.dates,
      required this.selectedDate,
      required this.onChanged,
      Key? key})
      : super(key: key);

  final List<DateTime> dates;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    DateFormat fullDate = DateFormat.yMMMEd("fr_BE");
    return ActionChip(
        onPressed: () async {
          DateTime? pickedDate = await showDatePicker(
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
        avatar: const Icon(Icons.calendar_today),
        label: Text(fullDate.format(selectedDate)));
  }

  static List<DropdownMenuItem<DateTime>> generateDropdownItems(
      List<DateTime> dates) {
    DateFormat fullDate = DateFormat.yMMMEd("fr_BE");
    return dates.map((DateTime walkDate) {
      return DropdownMenuItem<DateTime>(
          value: walkDate, child: Text(fullDate.format(walkDate)));
    }).toList();
  }
}
