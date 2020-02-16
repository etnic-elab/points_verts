import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:developer';

import 'walk_date.dart';

const String TAG = "dev.alpagaga.points_verts.DBProvider";

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();
  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await getDatabaseInstance();
    return _database;
  }

  Future<Database> getDatabaseInstance() async {
    log("Creating new database client", name: TAG);
    return openDatabase(
        join(await getDatabasesPath(), 'points_verts_database.db'),
        onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE walk_dates(id INTEGER PRIMARY KEY, date DATE)",
      );
    }, version: 1);
  }

  Future<List<WalkDate>> getWalkDates() async {
    log("Retrieving walk dates from database", name: TAG);
    final Database db = await database;
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final List<Map<String, dynamic>> maps = await db.query('walk_dates',
        where: 'date >= ?', whereArgs: [today.toIso8601String()]);
    return List.generate(maps.length, (i) {
      return WalkDate(id: maps[i]['id'], date: DateTime.parse(maps[i]['date']));
    });
  }

  Future<void> insertWalkDates(List<WalkDate> walkDates) async {
    log("Inserting walk dates in database", name: TAG);
    final Database db = await database;
    final Batch batch = db.batch();
    for (WalkDate walkDate in walkDates) {
      batch.insert("walk_dates", walkDate.toMap());
    }
    await batch.commit();
  }

  Future<int> removeWalkDates() async {
    log("Removing walk dates from database", name: TAG);
    final Database db = await database;
    return db.delete('walk_dates');
  }
}
