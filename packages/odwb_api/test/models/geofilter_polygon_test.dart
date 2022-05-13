import 'package:flutter_test/flutter_test.dart';
import 'package:meta_points_verts_adeps_api/odwb_api.dart';

void main() {
  group('GeofilterPolygon', () {
    group('toString', () {
      test('returns correct string', () {
        const geofilterPolygon = GeofilterPolygon(
            latLngOne: LatLng(latitude: 50.55, longitude: 51.55),
            latLngTwo: LatLng(latitude: 52.55, longitude: 53.55),
            latLngThree: LatLng(latitude: 54.55, longitude: 55.55));
        expect(
            '$geofilterPolygon', '(50.55,51.55),(52.55,53.55),(54.55,55.55)');
      });
    });
  });
}
