import 'package:equatable/equatable.dart';
import 'package:json_map_typedef/json_map_typedef.dart';
import 'package:maps_api/src/models/geolocation.dart';

/// Represents an address with formatted text and geographical coordinates.
class Address extends Equatable {
  /// Creates an [Address] instance.
  ///
  /// [mainText] is the human-readable address.
  /// [geolocation] is the geographical location of the address.
  const Address({
    required this.mainText,
    required this.geolocation,
  });

  /// Creates an [Address] instance from a JSON map.
  ///
  /// The JSON map must contain 'mainText' and 'geolocation' keys.
  factory Address.fromJson(JsonMap json) {
    return Address(
      mainText: json['mainText'] as String,
      geolocation: Geolocation.fromJson(json['geolocation'] as JsonMap),
    );
  }

  /// The human-readable formatted address text.
  final String mainText;

  /// The geographical location of the address.
  final Geolocation geolocation;

  /// Converts the address instance to a JSON map.
  ///
  /// Returns a Map with 'mainText' and 'geolocation' keys.
  JsonMap toJson() {
    return {
      'mainText': mainText,
      'geolocation': geolocation.toJson(),
    };
  }

  @override
  List<Object?> get props => [mainText, geolocation];
}
