import 'package:path/path.dart';
import 'package:points_verts/models/walk.dart';
import 'package:points_verts/models/walk_filter.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:developer';

const String tag = "dev.alpagaga.points_verts.DBProvider";

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database as Database;
    _database = await getDatabaseInstance();
    return _database as Database;
  }

  Future<Database> getDatabaseInstance() async {
    log("Creating new database client", name: tag);
    return openDatabase(
        join(await getDatabasesPath(), 'points_verts_database.db'),
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        version: 7);
  }

  Future<void> _createWalkTable(Database db) async {
    await PrefsProvider.prefs.remove(Prefs.lastWalkUpdate);
    await db.execute("DROP table IF EXISTS walks");
    await db.execute(
        "CREATE TABLE walks(id INTEGER PRIMARY KEY, city TEXT, entity TEXT, type TEXT, province TEXT, date DATE, longitude DOUBLE, latitude DOUBLE, status TEXT, meeting_point TEXT, meeting_point_info TEXT, organizer TEXT, contact_first_name TEXT, contact_last_name TEXT, contact_phone_number TEXT, ign TEXT, transport TEXT, fifteen_km TINYINT, wheelchair TINYINT, stroller TINYINT, extra_orientation TINYINT, extra_walk TINYINT, guided TINYINT, bike TINYINT, mountain_bike TINYINT, water_supply TINYINT, be_wapp TINYINT, adep_sante TINYINT, last_updated DATETIME, paths TEXT)");
    await db.execute("CREATE INDEX walks_date_index on walks(date)");
    await db.execute("CREATE INDEX walks_city_index on walks(city)");
  }

  void _onCreate(Database db, int version) async {
    await _createWalkTable(db);
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion <= 5) {
      await _createWalkTable(db);
    }
  }

  Future<List<DateTime>> getWalkDates() async {
    final Database db = await database;
    final now = DateTime.now();
    final lastMidnight = DateTime(now.year, now.month, now.day);
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
    log("Inserting ${walks.length} walks in database", name: tag);
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
    final lastMidnight = DateTime(now.year, now.month, now.day);
    log("Deleting old walks before $lastMidnight", name: tag);
    final Database db = await database;
    return await db.delete("walks",
        where: 'date < ?', whereArgs: [lastMidnight.toIso8601String()]);
  }

  Future<List<Walk>> getSortedWalks({WalkFilter? filter}) async {
    final Database db = await database;
    List<Map<String, dynamic>> maps;
    if (filter != null) {
      maps = await db.query('walks',
          where: _generateWhereFromFilter(filter),
          whereArgs: _generateArgsFromFilter(filter),
          orderBy: "city ASC");
    } else {
      maps = await db.query('walks', orderBy: "city ASC");
    }
    return List.generate(maps.length, (i) {
      return Walk.fromDb(maps, i);
    });
  }

  String _generateWhereFromFilter(WalkFilter filter) {
    String where = "1=1";
    if (filter.filterByProvince()) {
      List<String> provinces = filter.provinceFilter();
      where = where + " and province in ${provinces.map((e) => "?")}";
    }
    if (!filter.cancelledWalks) {
      where = where + " and status != ?";
    }
    if (filter.fifteenKm) where = where + " and fifteen_km = 1";
    if (filter.wheelchair) where = where + " and wheelchair = 1";
    if (filter.stroller) where = where + " and stroller = 1";
    if (filter.extraOrientation) where = where + " and extra_orientation = 1";
    if (filter.extraWalk) where = where + " and extra_walk = 1";
    if (filter.guided) where = where + " and guided = 1";
    if (filter.bike) where = where + " and bike = 1";
    if (filter.mountainBike) where = where + " and mountain_bike = 1";
    if (filter.waterSupply) where = where + " and water_supply = 1";
    if (filter.beWapp) where = where + " and be_wapp = 1";
    if (filter.adepSante) where = where + " and adep_sante = 1";
    if (filter.transport) where = where + " and transport is not null";
    return where;
  }

  List<dynamic> _generateArgsFromFilter(WalkFilter filter) {
    List<dynamic> args = [];
    if (filter.filterByProvince()) {
      List<String> provinces = filter.provinceFilter();
      args.addAll(provinces);
    }
    if (!filter.cancelledWalks) {
      args.add("Annulé");
    }
    return args;
  }

  Future<List<Walk>> getWalks(DateTime? date, {WalkFilter? filter}) async {
    log("Retrieving walks from database for $date", name: tag);
    if (date == null) return [];
    final Database? db = await database;
    List<Map<String, dynamic>> maps;
    if (filter != null) {
      String where = "date = ?" + _generateWhereFromFilter(filter);
      List<dynamic> args = [date.toIso8601String()];
      args.addAll(_generateArgsFromFilter(filter));
      maps = await db!.query('walks', where: where, whereArgs: args);
    } else {
      maps = await db!.query('walks',
          where: 'date = ?', whereArgs: [date.toIso8601String()]);
    }
    return List.generate(maps.length, (i) {
      return Walk.fromDb(maps, i);
    });
  }

  Future<Walk?> getWalk(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('walks', where: 'id = ?', whereArgs: [id]);
    if (maps.length == 1) {
      return Walk.fromDb(maps, 0);
    } else {
      return null;
    }
  }
}
