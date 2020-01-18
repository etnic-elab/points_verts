import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'walk_date.dart';

Future<List<WalkDate>> getWalkDates() async {
  final Database db = await _database();
  final DateTime today = DateTime.now();
  final List<Map<String, dynamic>> maps = await db.query('walk_dates',
      where: 'date >= ?', whereArgs: [today.toIso8601String()]);
  return List.generate(maps.length, (i) {
    return WalkDate(id: maps[i]['id'], date: DateTime.parse(maps[i]['date']));
  });
}

Future<void> insertWalkDates(List<WalkDate> walkDates) async {
  final Database db = await _database();
  final Batch batch = db.batch();
  for (WalkDate walkDate in walkDates) {
    batch.insert("walk_dates", walkDate.toMap());
  }
  await batch.commit();
}

Future<Database> _database() async {
  return openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'points_verts_database.db'),
      onCreate: (db, version) {
    return db.execute(
      "CREATE TABLE walk_dates(id INTEGER PRIMARY KEY, date DATE)",
    );
  }, version: 1);
}
