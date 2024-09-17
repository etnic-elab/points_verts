import 'dart:convert';
import 'dart:developer';

import 'package:cache_manager/src/models/models.dart';
import 'package:jsonable/jsonable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// {@template cache_manager}
/// A service which caches api calls in memory and persistant cache
/// {@endtemplate}
abstract class CacheManager<T> {
  /// {@macro cache_manager}
  CacheManager({
    required String persistentCacheKey,
    Duration? defaultExpiration,
    int? maxCacheSize,
  })  : _persistentCacheKey = persistentCacheKey,
        _defaultExpiration = defaultExpiration,
        _maxCacheSize = maxCacheSize ?? 100;

  final Map<String, CachedItem<dynamic>> _memoryCache = {};
  final String _persistentCacheKey;
  final Duration? _defaultExpiration;
  final int _maxCacheSize;

  T fromJsonT(dynamic json);

  Future<T> get(
    String key,
    Future<T> Function() fetchFunction,
  ) async {
    // Check memory cache
    if (_memoryCache.containsKey(key) && !_memoryCache[key]!.isExpired()) {
      log('Retrieved from memory cache');
      return _memoryCache[key]!.data as T;
    }

    // Check persistent cache
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_persistentCacheKey);
    if (cachedData != null) {
      final allCachedItems = jsonDecode(cachedData) as JsonMap;
      if (allCachedItems.containsKey(key)) {
        final cachedItem = CachedItem.fromJson<T>(
          allCachedItems[key] as JsonMap,
          fromJsonT,
        );
        if (!cachedItem.isExpired()) {
          _memoryCache[key] = cachedItem;
          log('Retrieved from persistent cache');
          return cachedItem.data;
        }
      }
    }

    // Fetch new data
    final data = await fetchFunction();

    // Cache the new data
    await set(key, data);

    log('Retrieved from API Call');

    return data;
  }

  Future<void> set(
    String key,
    T data, {
    Duration? expiration,
  }) async {
    final cachedItem = CachedItem(
      data: data,
      timestamp: DateTime.now(),
      expiration: expiration ?? _defaultExpiration,
    );

    // Update memory cache
    _memoryCache[key] = cachedItem;

    // Update persistent cache
    final prefs = await SharedPreferences.getInstance();
    final existingCache = prefs.getString(_persistentCacheKey);
    final JsonMap allCachedItems =
        existingCache != null ? (jsonDecode(existingCache) as JsonMap) : {};

    allCachedItems[key] = cachedItem.toJson();

    // Limit cache size
    if (allCachedItems.length > _maxCacheSize) {
      final sortedEntries = allCachedItems.entries.toList()
        ..sort(
          (a, b) => CachedItem.fromJson<dynamic>(
            b.value as JsonMap,
            (json) => json,
          ).timestamp.compareTo(
                CachedItem.fromJson<dynamic>(
                  a.value as JsonMap,
                  (json) => json,
                ).timestamp,
              ),
        );
      allCachedItems
        ..clear()
        ..addEntries(sortedEntries.take(_maxCacheSize));
    }

    await prefs.setString(_persistentCacheKey, jsonEncode(allCachedItems));
  }

  Future<void> remove(String key) async {
    _memoryCache.remove(key);

    final prefs = await SharedPreferences.getInstance();
    final existingCache = prefs.getString(_persistentCacheKey);
    if (existingCache != null) {
      final allCachedItems = jsonDecode(existingCache) as JsonMap..remove(key);
      await prefs.setString(_persistentCacheKey, jsonEncode(allCachedItems));
    }
  }

  Future<void> clear() async {
    _memoryCache.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_persistentCacheKey);
  }

  Future<void> removeExpiredEntries() async {
    _memoryCache.removeWhere((_, item) => item.isExpired());

    final prefs = await SharedPreferences.getInstance();
    final existingCache = prefs.getString(_persistentCacheKey);
    if (existingCache != null) {
      final allCachedItems = jsonDecode(existingCache) as JsonMap
        ..removeWhere(
          (_, value) => CachedItem.fromJson<dynamic>(
            value as JsonMap,
            (json) => json,
          ).isExpired(),
        );
      await prefs.setString(_persistentCacheKey, jsonEncode(allCachedItems));
    }
  }
}
