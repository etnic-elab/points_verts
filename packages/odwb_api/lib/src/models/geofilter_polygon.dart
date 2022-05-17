import 'package:equatable/equatable.dart';
import 'package:meta_points_verts_adeps_api/odwb_api.dart';

class GeofilterPolygon extends Equatable {
  const GeofilterPolygon({
    required this.latLngOne,
    required this.latLngTwo,
    required this.latLngThree,
  });

  final LatLng latLngOne;
  final LatLng latLngTwo;
  final LatLng latLngThree;

  @override
  String toString() => '($latLngOne),($latLngTwo),($latLngThree)';

  @override
  List<Object?> get props => [latLngOne, latLngTwo, latLngThree];
}
