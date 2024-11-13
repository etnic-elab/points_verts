import 'package:equatable/equatable.dart';
import 'package:json_map_typedef/json_map_typedef.dart';
import 'package:maps_api/maps_api.dart' show Geolocation;

class TrailPoint extends Equatable {
  const TrailPoint({
    required this.location,
    this.elevation,
  });

  factory TrailPoint.fromJson(JsonMap json) {
    return TrailPoint(
      location: Geolocation.fromJson(json['location'] as JsonMap),
      elevation: json['elevation'] as double?,
    );
  }

  final Geolocation location;
  final double? elevation;

  @override
  List<Object?> get props => [location, elevation];

  JsonMap toJson() {
    return {
      'location': location.toJson(),
      'elevation': elevation,
    };
  }
}
