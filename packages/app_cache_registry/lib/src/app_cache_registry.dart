import 'package:app_cache_registry/src/models/adeps_website_cache_manager.dart';
import 'package:app_cache_registry/src/models/models.dart';
import 'package:app_cache_registry/src/models/odwb_cache_manager.dart';
import 'package:cache_manager/cache_manager.dart';

/// {@template app_cache_registry}
/// A registry for all the caches used in the application
/// {@endtemplate}
class AppCacheRegistry {
  /// {@macro app_cache_registry}
  AppCacheRegistry._();

  static final Map<Type, CacheManager<dynamic>> _cacheManagers = {};

  static void register<T extends CacheManager<dynamic>>(T cacheManager) {
    _cacheManagers[T] = cacheManager;
  }

  static T get<T extends CacheManager<dynamic>>() {
    final cacheManager = _cacheManagers[T];
    if (cacheManager == null) {
      throw CacheManagerNotRegisteredException(T);
    }
    return cacheManager as T;
  }

  static void initializeCaches() {
    register(TripsCacheManager());
    register(WeatherCacheManager());
    register(AdepsWebsiteCacheManager());
    register(OdwbCacheManager());
    // Register more caches as needed
  }

  static Future<void> cleanupAllCaches() async {
    for (final cacheManager in _cacheManagers.values) {
      await cacheManager.removeExpiredEntries();
    }
  }
}

class CacheManagerNotRegisteredException implements Exception {
  CacheManagerNotRegisteredException(this.type);

  final Type type;

  @override
  String toString() => 'CacheManager for type $type is not registered.';
}
