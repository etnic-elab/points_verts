DateTime getNextSunday() {
  DateTime current = new DateTime.now();
  Duration oneDay = new Duration(days: 1);
  while (current.weekday != DateTime.sunday) {
    current = current.add(oneDay);
  }
  return current;
}

List<DateTime> generateDates() {
  List<DateTime> results = new List<DateTime>();
  DateTime current = new DateTime.now();
  Duration oneDay = new Duration(days: 1);
  Duration aWeek = new Duration(days: 7);
  while (current.weekday != DateTime.sunday) {
    current = current.add(oneDay);
  }
  while (results.length < 10) {
    results.add(current);
    current = current.add(aWeek);
  }
  return results;
}
