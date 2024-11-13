import 'package:app_cache_registry/app_cache_registry.dart'
    show
        AdepsWebsiteCacheManager,
        OdwbCacheManager,
        TrailParserCacheManager,
        TripsCacheManager,
        WeatherCacheManager;
import 'package:persistent_storage_manager/persistent_storage_manager.dart';
import 'package:service_registry/service_registry.dart' show ServiceRegistry;

/// App specific cache registry
/// App specific cache registry
/// App specific cache registry
class AppCacheRegistry extends ServiceRegistry {
  AppCacheRegistry._(); // Private constructor

  // Required override of the instance getter
  static final AppCacheRegistry instance = AppCacheRegistry._();

  Future<void> initializeCaches({
    SharedPreferences? prefs,
  }) async {
    if (isInitialized) {
      throw StateError('Cannot register services after initialization');
    }

    prefs ??= await SharedPreferences.getInstance();

    registerService<TripsCacheManager>(
      TripsCacheManager(prefs: prefs),
    );

    registerService<WeatherCacheManager>(
      WeatherCacheManager(prefs: prefs),
    );

    registerService<AdepsWebsiteCacheManager>(
      AdepsWebsiteCacheManager(prefs: prefs),
    );

    registerService<OdwbCacheManager>(
      OdwbCacheManager(prefs: prefs),
    );

    registerService<TrailParserCacheManager>(
      TrailParserCacheManager(prefs: prefs),
    );

    await initialize();
  }
}
