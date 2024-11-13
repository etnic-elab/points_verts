import 'package:json_map_typedef/json_map_typedef.dart';
import 'package:maps_api/maps_api.dart' show Address;
import 'package:persistent_storage_manager/persistent_storage_manager.dart'
    show PersistentStorageManager;

class HomeAddressStorage extends PersistentStorageManager<Address> {
  HomeAddressStorage({
    required super.prefs,
  }) : super(
          persistentKey: 'home_address',
        );

  Future<Address?> get() => getValue();

  @override
  Address fromJson(dynamic json) {
    if (json is JsonMap) {
      return Address.fromJson(json);
    }
    throw FormatException('Expected a JsonMap, but got ${json.runtimeType}');
  }

  @override
  JsonMap toJson(Address value) => value.toJson();
}
