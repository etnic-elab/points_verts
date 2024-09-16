import 'package:address_repository/address_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final locator = GetIt.instance;

void setupLocator() {
  // Register AddressRepository as a lazy singleton
  locator.registerLazySingleton<AddressRepository>(() {
    final provider = dotenv.env['MAP_API'] ?? '';
    final apiKey = dotenv.env['MAP_API_KEY'] ?? '';
    return AddressRepositoryFactory.create(provider, apiKey);
  });
}
