import 'package:path/path.dart';
import 'package:points_verts/models/walk.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:developer';

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
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        version: 5);
  }

  Future<void> _createWalkTable(Database db) async {
    await PrefsProvider.prefs.setString("last_walk_update", null);
    await db.execute("DROP table IF EXISTS walks");
    await db.execute(
        "CREATE TABLE walks(id INTEGER PRIMARY KEY, city TEXT, entity TEXT, type TEXT, province TEXT, date DATE, longitude DOUBLE, latitude DOUBLE, status TEXT, meeting_point TEXT, meeting_point_info TEXT, organizer TEXT, contact_first_name TEXT, contact_last_name TEXT, contact_phone_number TEXT, transport TEXT, fifteen_km TINYINT, wheelchair TINYINT, stroller TINYINT, extra_orientation TINYINT, extra_walk TINYINT, guided TINYINT, bike TINYINT, mountain_bike TINYINT, water_supply TINYINT, be_wapp TINYINT, last_updated DATETIME)");
    await db.execute("CREATE INDEX walks_date_index on walks(date)");
    await db.execute("CREATE INDEX walks_city_index on walks(city)");
  }

  void _onCreate(Database db, int version) async {
    await _createWalkTable(db);
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion <= 4) {
      await _createWalkTable(db);
    }
  }

  Future<List<DateTime>> getWalkDates() async {
    final Database db = await database;
    final now = DateTime.now();
    final lastMidnight = new DateTime(now.year, now.month, now.day);
    final List<Map<String, dynamic>> maps = await db.query('walks',
        columns: ['date'],
        groupBy: "date",
        orderBy: "date ASC",
        where: 'date >= ?',
        whereArgs: [lastMidnight.toIso8601String()]);
    return List.generate(maps.length, (i) {
      return DateTime.parse(maps[i]['date']);
    });
  }

  Future<void> insertWalks(List<Walk> walks) async {
    log("Inserting ${walks.length} walks in database", name: TAG);
    final Database db = await database;
    final Batch batch = db.batch();
    for (Walk walk in walks) {
      batch.insert("walks", walk.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();
  }

  Future<int> deleteOldWalks() async {
    final now = DateTime.now();
    final lastMidnight = new DateTime(now.year, now.month, now.day);
    log("Deleting old walks before $lastMidnight", name: TAG);
    final Database db = await database;
    return await db.delete("walks",
        where: 'date < ?', whereArgs: [lastMidnight.toIso8601String()]);
  }

  Future<List<Walk>> getSortedWalks() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('walks', orderBy: "city ASC");
    return List.generate(maps.length, (i) {
      return _fromDb(maps, i);
    });
  }

  Future<List<Walk>> getWalks(DateTime date) async {
    log("Retrieving walks from database for $date", name: TAG);
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db
        .query('walks', where: 'date = ?', whereArgs: [date.toIso8601String()]);
    return List.generate(maps.length, (i) {
      return _fromDb(maps, i);
    });
  }

  Walk _fromDb(List<Map<String, dynamic>> maps, int i) {
    return Walk(
        id: maps[i]['id'],
        city: maps[i]['city'],
        entity: maps[i]['entity'],
        type: maps[i]['type'],
        province: maps[i]['province'],
        date: DateTime.parse(maps[i]['date']),
        long: maps[i]['longitude'],
        lat: maps[i]['latitude'],
        status: maps[i]['status'],
        meetingPoint: maps[i]['meeting_point'],
        meetingPointInfo: maps[i]['meeting_point_info'],
        organizer: maps[i]['organizer'],
        contactFirstName: maps[i]['contact_first_name'],
        contactLastName: maps[i]['contact_last_name'],
        contactPhoneNumber: maps[i]['contact_phone_number'] != null
            ? maps[i]['contact_phone_number'].toString()
            : null,
        transport: maps[i]['transport'],
        fifteenKm: maps[i]['fifteen_km'] == 1 ? true : false,
        wheelchair: maps[i]['wheelchair'] == 1 ? true : false,
        stroller: maps[i]['stroller'] == 1 ? true : false,
        extraOrientation: maps[i]['extra_orientation'] == 1 ? true : false,
        extraWalk: maps[i]['extra_walk'] == 1 ? true : false,
        guided: maps[i]['guided'] == 1 ? true : false,
        bike: maps[i]['bike'] == 1 ? true : false,
        mountainBike: maps[i]['mountain_bike'] == 1 ? true : false,
        waterSupply: maps[i]['water_supply'] == 1 ? true : false,
        beWapp: maps[i]['be_wapp'] == 1 ? true : false,
        lastUpdated: DateTime.parse(maps[i]['last_updated']));
  }
}
