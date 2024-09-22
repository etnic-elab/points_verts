import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:maps_repository/maps_repository.dart';

final locator = GetIt.instance;

void setupLocator() {
  // Register AddressRepository as a lazy singleton
  locator.registerLazySingleton<MapsRepository>(() {
    final provider = dotenv.env['MAP_API'] ?? '';
    final apiKey = dotenv.env['MAP_API_KEY'] ?? '';
    return MapsRepositoryFactory.create(provider, apiKey);
  });
}
