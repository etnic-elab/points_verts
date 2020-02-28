import '../../services/database.dart';
import '../../services/prefs.dart';
import '../../services/adeps.dart';
import '../../models/walk_date.dart';

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

Future<List<WalkDate>> getWalkDates() async {
  int datesLastUpdate = await PrefsProvider.prefs.getInt("dates_last_update");
  bool needsUpdate = datesLastUpdate == null ||
      DateTime.fromMillisecondsSinceEpoch(datesLastUpdate)
          .difference(DateTime.now()) >
          Duration(days: 7);
  List<WalkDate> walkDates;
  if (needsUpdate) {
    try {
      walkDates = await _getWalkDatesFromEndpoint();
      if (walkDates.length != 0) {
        DBProvider.db.removeWalkDates();
        DBProvider.db.insertWalkDates(walkDates);
        return walkDates;
      }
    } catch (err) {
      print("Cannot update walk dates: $err");
    }
  }
  walkDates = await DBProvider.db.getWalkDates();
  if (walkDates.length == 0) {
    walkDates = await _getWalkDatesFromEndpoint();
  }
  return walkDates;
}

Future<List<WalkDate>> _getWalkDatesFromEndpoint() async {
  List<DateTime> dates = await retrieveDatesFromWorker();
  List<WalkDate> walkDates = dates.map((DateTime date) {
    return WalkDate(date: date);
  }).toList();
  PrefsProvider.prefs
      .setInt("dates_last_update", DateTime.now().millisecondsSinceEpoch);
  return walkDates;
}
