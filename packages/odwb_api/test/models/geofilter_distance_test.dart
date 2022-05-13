import 'package:flutter_test/flutter_test.dart';
import 'package:meta_points_verts_adeps_api/odwb_api.dart';

void main() {
  group('GeofilterDistance', () {
    group('toString', () {
      test('returns correct string', () {
        const geofilterDistance = GeofilterDistance(
            latLng: LatLng(latitude: 50.5555, longitude: 55.0), distance: 2000);
        expect('$geofilterDistance', '50.5555,55.0,2000');
      });
    });
  });
}
