import 'package:app_user_preferences_registry/app_user_preferences_registry.dart'
    show DefaultMapTypeStorage, HomeAddressStorage;
import 'package:persistent_storage_manager/persistent_storage_manager.dart'
    show SharedPreferences;
import 'package:service_registry/service_registry.dart' show ServiceRegistry;

/// App specific cache registry
class AppUserPreferencesRegistry extends ServiceRegistry {
  /// Private constructor
  AppUserPreferencesRegistry._();

  /// Singleton instance
  static final AppUserPreferencesRegistry instance =
      AppUserPreferencesRegistry._();

  Future<void> initializeUserPreferences({
    SharedPreferences? prefs,
  }) async {
    if (isInitialized) {
      throw StateError('Cannot register services after initialization');
    }

    prefs ??= await SharedPreferences.getInstance();

    registerService<HomeAddressStorage>(
      HomeAddressStorage(prefs: prefs),
    );

    registerService<DefaultMapTypeStorage>(
      DefaultMapTypeStorage(prefs: prefs),
    );

    await initialize();
  }
}
