import 'package:equatable/equatable.dart';

class LatLng extends Equatable {
  const LatLng({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  String toString() => '$latitude,$longitude';

  @override
  List<Object?> get props => [latitude, longitude];
}
