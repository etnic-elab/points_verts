import 'package:maps_api/src/models/geolocation.dart';

/// Represents an address with formatted text and geographical coordinates.
class Address {
  /// Creates an [Address] instance.
  ///
  /// [mainText] is the human-readable address.
  /// [geolocation] is the geographical location of the address.
  Address({
    required this.mainText,
    required this.geolocation,
  });

  /// The human-readable formatted address text.
  final String mainText;

  /// The geographical location of the address.
  final Geolocation geolocation;
}
