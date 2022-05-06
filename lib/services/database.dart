import 'package:path/path.dart';
import 'package:points_verts/models/walk.dart';
import 'package:points_verts/models/walk_filter.dart';
import 'package:points_verts/services/service_locator.dart';
import 'package:points_verts/models/walk_sort.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:developer';

const String tag = "dev.alpagaga.points_verts.DBProvider";

class DBProvider {
  late final Future<Database> _database;

  DBProvider() {
    _database = initDatabase();
  }

  Future<Database> get database => _database;

  Future<Database> initDatabase() async {
    log("Creating new database client", name: tag);
    return openDatabase(
        join(await getDatabasesPath(), 'points_verts_database.db'),
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        version: 8);
  }

  Future<void> _createWalkTable(Database db) async {
    await prefs.remove(Prefs.lastWalkUpdate);
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
    if (oldVersion <= 7) {
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

    return List.generate(maps.length, (i) => DateTime.parse(maps[i]['date']));
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

  String _generateWhereFromFilter(WalkFilter filter) {
    Set<String> wheres = {'1=1'};
    if (filter.filterByProvince) {
      wheres.add('province in ${filter.provinceFilter.map((e) => "?")}');
    }

    if (filter.date != null) wheres.add('date = ?');
    if (!filter.cancelledWalks.value) wheres.add('status != ?');
    if (filter.fifteenKm.value) wheres.add('fifteen_km = 1');
    if (filter.wheelchair.value) wheres.add('wheelchair = 1');
    if (filter.stroller.value) wheres.add('stroller = 1');
    if (filter.extraOrientation.value) wheres.add('extra_orientation = 1');
    if (filter.extraWalk.value) wheres.add('extra_walk = 1');
    if (filter.guided.value) wheres.add('guided = 1');
    if (filter.bike.value) wheres.add('bike = 1');
    if (filter.mountainBike.value) wheres.add('mountain_bike = 1');
    if (filter.waterSupply.value) wheres.add('water_supply = 1');
    if (filter.beWapp.value) wheres.add('be_wapp = 1');
    if (filter.adepSante.value) wheres.add('adep_sante = 1');
    if (filter.transport.value) wheres.add('transport is not null');
    return wheres.join(' and ');
  }

  List<dynamic> _generateArgsFromFilter(WalkFilter filter) {
    List<dynamic> args = [];
    if (filter.filterByProvince) args.addAll(filter.provinceFilter);
    if (filter.date != null) args.add(filter.date!.toIso8601String());
    if (!filter.cancelledWalks.value) args.add("Annulé");

    return args;
  }

  Future<List<Walk>> getWalks({WalkFilter? filter, SortBy? sortBy}) async {
    List<Map<String, dynamic>> maps;
    String? where;
    List<dynamic>? whereArgs;
    String? orderBy;

    if (filter != null) {
      where = _generateWhereFromFilter(filter);
      whereArgs = _generateArgsFromFilter(filter);
    }

    sortBy = sortBy ?? SortBy.defaultValue();
    if (!sortBy.position) {
      orderBy = '${sortBy.type.name} ${sortBy.direction.name}, city ASC';
    }

    final Database db = await database;
    maps = await db.query('walks',
        where: where, whereArgs: whereArgs, orderBy: orderBy);
    return List.generate(maps.length, (i) => Walk.fromDb(maps[i]));
  }

  Future<Walk?> getWalk(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('walks', where: 'id = ?', whereArgs: [id]);
    if (maps.length == 1) {
      return Walk.fromDb(maps[0]);
    } else {
      return null;
    }
  }
}
