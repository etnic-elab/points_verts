import 'package:jsonable/jsonable.dart';
import 'package:maps_api/maps_api.dart';

class GoogleAddressSuggestionFactory {
  static AddressSuggestion fromJson(JsonMap json) {
    final structuredFormatting = json['structured_formatting'] as JsonMap;

    return AddressSuggestion(
      mainText: structuredFormatting['main_text'] as String,
      description: json['description'] as String,
      placeId: json['place_id'] as String,
    );
  }
}
