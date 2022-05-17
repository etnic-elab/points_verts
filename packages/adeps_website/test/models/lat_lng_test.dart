import 'package:adeps_website/adeps_website.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LatLng', () {
    group('toString', () {
      test('returns correct string', () {
        const latLng = LatLng(latitude: 50.5555, longitude: 55.0);
        expect('$latLng', '50.5555,55.0');
      });
    });
  });
}
