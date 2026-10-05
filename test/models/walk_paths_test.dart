import 'package:flutter_test/flutter_test.dart';
import 'package:points_verts/models/path.dart';
import 'package:points_verts/models/walk.dart';

Map<String, dynamic> _pathJson(String? jourdemarche) => {
      'fichier': 'https://example.org/trace.gpx',
      'titre': 'Parcours',
      'couleur': '1',
      'jourdemarche': ?jourdemarche,
    };

Walk _walk(DateTime date, List<Path> paths) => Walk(
      id: 1,
      city: 'City',
      entity: 'Entity',
      type: 'Marche',
      province: 'Namur',
      long: 4.0,
      lat: 50.0,
      date: date,
      status: 'OK',
      meetingPoint: null,
      meetingPointInfo: null,
      organizer: 'Org',
      contactFirstName: 'First',
      contactLastName: 'Last',
      contactPhoneNumber: null,
      ign: null,
      transport: null,
      fifteenKm: false,
      wheelchair: false,
      stroller: false,
      extraOrientation: false,
      extraWalk: false,
      guided: false,
      bike: false,
      mountainBike: false,
      waterSupply: false,
      beWapp: false,
      adepSante: false,
      lastUpdated: DateTime.now(),
      paths: paths,
    );

void main() {
  group('Path jourdemarche', () {
    test('parses the flag', () {
      expect(Path.fromJsonIfGpx(_pathJson('1'))!.walkDayOnly, isTrue);
      expect(Path.fromJsonIfGpx(_pathJson('0'))!.walkDayOnly, isFalse);
      expect(Path.fromJsonIfGpx(_pathJson(null))!.walkDayOnly, isFalse);
    });

    test('survives a toJson round-trip', () {
      final path = Path.fromJsonIfGpx(_pathJson('1'))!;
      expect(Path.fromJsonIfGpx(path.toJson())!.walkDayOnly, isTrue);
    });
  });

  group('Walk.visiblePaths', () {
    final always = Path.fromJsonIfGpx(_pathJson('0'))!;
    final walkDayOnly = Path.fromJsonIfGpx(_pathJson('1'))!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    test('shows all paths on the day of the walk', () {
      final walk = _walk(today, [always, walkDayOnly]);
      expect(walk.visiblePaths, [always, walkDayOnly]);
    });

    test('hides walk-day-only paths on other days', () {
      final walk =
          _walk(today.add(const Duration(days: 1)), [always, walkDayOnly]);
      expect(walk.visiblePaths, [always]);
    });
  });
}
