class Address {
  Address({
    required this.address,
    required this.longitude,
    required this.latitude,
  });

  final String address;
  final double longitude;
  final double latitude;
}

class AddressSuggestion {
  final String placeId;
  final String name;
  final String description;
  final double? longitude;
  final double? latitude;

  AddressSuggestion(
      this.placeId, this.name, this.description, this.longitude, this.latitude);

  @override
  String toString() {
    return 'Suggestion(description: $description, name: $name, placeId: $placeId)';
  }
}
