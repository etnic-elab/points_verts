import 'package:adeps_website/adeps_website.dart';
import 'package:flutter_test/flutter_test.dart';

// 16592;MELLET;M;50.502424;4.4726926;Hainaut;09-01-2022;Dimanche 9 Janvier 2022;Les Bons Villers;ptvert;16593;NIVELLES;M;50.59777889999999;4.3364015;Brabant Wallon;09-01-2022;Dimanche 9 Janvier 2022;Nivelles;ptvert_annule
void main() {
  group('Point', () {
    group('fromList', () {
      test('returns Enum.unknown for unsupported enums', () {
        expect(
            Point.fromList(const [
              16592,
              'MELLET',
              '-',
              50.502424,
              4.4726926,
              'Hainaut',
              '09-01-2022',
              'Dimanche 9 Janvier 2022',
              'Les Bons Villers',
              '-'
            ]),
            isA<Point>()
                .having(
                  (p) => p.status,
                  'status',
                  Status.unknown,
                )
                .having(
                  (p) => p.activity,
                  'activity',
                  Activity.unknown,
                ));
      });
    });
  });
}
