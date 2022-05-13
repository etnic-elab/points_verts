import 'package:flutter_test/flutter_test.dart';
import 'package:meta_points_verts_adeps_api/odwb_api.dart';

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
