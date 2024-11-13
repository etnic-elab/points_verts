import 'dart:developer';

import 'package:path/path.dart';
import 'package:points_verts/models/walk.dart';
import 'package:points_verts/models/walk_filter.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:sqflite/sqflite.dart';

const String tag = 'dev.alpagaga.points_verts.DBProvider';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();
  Future<Database>? _database;

  Future<Database> get database => _database ??= getDatabaseInstance();

  Future<Database> getDatabaseInstance() async {
    log('Creating new database client', name: tag);
    return openDatabase(
        join(await getDatabasesPath(), 'points_verts_database.db'),
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        version: 9,);
  }

  Future<void> _createWalkTable(Database db) async {
    await PrefsProvider.prefs.remove(Prefs.lastWalkUpdate);
    await db.execute('DROP table IF EXISTS walks');
    await db.execute(
        'CREATE TABLE walks(id INTEGER PRIMARY KEY, city TEXT, entity TEXT, type TEXT, province TEXT, date DATE, longitude DOUBLE, latitude DOUBLE, status TEXT, meeting_point TEXT, meeting_point_info TEXT, organizer TEXT, contact_first_name TEXT, contact_last_name TEXT, contact_phone_number TEXT, ign TEXT, transport TEXT, fifteen_km TINYINT, wheelchair TINYINT, stroller TINYINT, extra_orientation TINYINT, extra_walk TINYINT, guided TINYINT, bike TINYINT, mountain_bike TINYINT, water_supply TINYINT, be_wapp TINYINT, adep_sante TINYINT, last_updated DATETIME, paths TEXT)',);
    await db.execute('CREATE INDEX walks_date_index on walks(date)');
    await db.execute('CREATE INDEX walks_city_index on walks(city)');
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createWalkTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion <= 8) {
      await _createWalkTable(db);
    }
  }

  Future<List<DateTime>> getWalkDates() async {
    final db = await database;
    final now = DateTime.now();
    final lastMidnight = DateTime(now.year, now.month, now.day);
    final List<Map<String, dynamic>> maps = await db.query('walks',
        columns: ['date'],
        groupBy: 'date',
        orderBy: 'date ASC',
        where: 'date >= ?',
        whereArgs: [lastMidnight.toIso8601String()],);
    return List.generate(maps.length, (i) => DateTime.parse(maps[i]['date']));
  }

  Future<List> insertWalks(List<Walk> walks) async {
    log('Inserting ${walks.length} walks in database', name: tag);
    final db = await database;
    final batch = db.batch();
    for (final walk in walks) {
      batch.insert('walks', walk.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,);
    }
    return batch.commit();
  }

  Future<int> deleteWalks() async {
    final db = await database;
    return db.delete('walks');
  }

  Future<int> deleteOldWalks(DateTime now) async {
    final lastMidnight = DateTime(now.year, now.month, now.day);
    final db = await database;
    final int deleted = await db.delete('walks',
        where: 'date < ?', whereArgs: [lastMidnight.toIso8601String()],);

    log('Deleted $deleted old walks before $lastMidnight', name: tag);
    return deleted;
  }

  Future<List<Walk>> getSortedWalks({WalkFilter? filter}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;
    if (filter != null) {
      maps = await db.query('walks',
          where: _generateWhereFromFilter(filter),
          whereArgs: _generateArgsFromFilter(filter),
          orderBy: 'city ASC',);
    } else {
      maps = await db.query('walks', orderBy: 'city ASC');
    }
    return List.generate(maps.length, (i) => Walk.fromDb(maps, i));
  }

  String _generateWhereFromFilter(WalkFilter filter) {
    var where = '1=1';
    if (filter.filterByProvince()) {
      final List<String> provinces = filter.provinceFilter();
      where = "$where and province in ${provinces.map((e) => "?")}";
    }
    if (!filter.cancelledWalks) {
      where = '$where and status != ?';
    }
    if (filter.fifteenKm) where = '$where and fifteen_km = 1';
    if (filter.wheelchair) where = '$where and wheelchair = 1';
    if (filter.stroller) where = '$where and stroller = 1';
    if (filter.extraOrientation) where = '$where and extra_orientation = 1';
    if (filter.extraWalk) where = '$where and extra_walk = 1';
    if (filter.guided) where = '$where and guided = 1';
    if (filter.bike) where = '$where and bike = 1';
    if (filter.mountainBike) where = '$where and mountain_bike = 1';
    if (filter.waterSupply) where = '$where and water_supply = 1';
    if (filter.beWapp) where = '$where and be_wapp = 1';
    if (filter.adepSante) where = '$where and adep_sante = 1';
    if (filter.transport) where = '$where and transport is not null';
    return where;
  }

  List<dynamic> _generateArgsFromFilter(WalkFilter filter) {
    final args = <dynamic>[];
    if (filter.filterByProvince()) {
      final List<String> provinces = filter.provinceFilter();
      args.addAll(provinces);
    }
    if (!filter.cancelledWalks) {
      args.add('Annulé');
    }
    return args;
  }

  Future<List<Walk>> getWalks(DateTime? date, {WalkFilter? filter}) async {
    log('Retrieving walks from database for $date', name: tag);
    if (date == null) return [];
    final db = await database;
    List<Map<String, dynamic>> maps;
    if (filter != null) {
      final where = 'date = ?${_generateWhereFromFilter(filter)}';
      final args = <dynamic>[date.toIso8601String()];
      args.addAll(_generateArgsFromFilter(filter));
      maps = await db.query('walks', where: where, whereArgs: args);
    } else {
      maps = await db.query('walks',
          where: 'date = ?', whereArgs: [date.toIso8601String()],);
    }
    return List.generate(maps.length, (i) => Walk.fromDb(maps, i));
  }

  Future<Walk?> getWalk(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('walks', where: 'id = ?', whereArgs: [id]);

    return maps.length == 1 ? Walk.fromDb(maps, 0) : null;
  }

  Future<bool> isWalkTableEmpty() async {
    final db = await database;
    final List results = await db.query('walks');
    return results.isEmpty;
  }
}
