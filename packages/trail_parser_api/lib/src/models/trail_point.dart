import 'package:equatable/equatable.dart';
import 'package:maps_api/maps_api.dart' show Geolocation;

class TrailPoint extends Equatable {
  const TrailPoint({
    required this.location,
    this.elevation,
  });

  factory TrailPoint.fromJson(Map<String, dynamic> json) {
    return TrailPoint(
      location: Geolocation.fromJson(json['location'] as Map<String, dynamic>),
      elevation: json['elevation'] as double?,
    );
  }

  final Geolocation location;
  final double? elevation;

  @override
  List<Object?> get props => [location, elevation];

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'elevation': elevation,
    };
  }
}
