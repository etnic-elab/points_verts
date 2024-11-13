import 'dart:async' show FutureOr;
import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:developer' as developer;

import 'package:json_map_typedef/json_map_typedef.dart';
import 'package:persistent_storage_manager/src/models/cached_value.dart'
    show CachedValue;
import 'package:service_registry/service_registry.dart' show Service;
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

abstract class PersistentStorageManager<T> implements Service {
  PersistentStorageManager({
    required this.prefs,
    required String persistentKey,
    this.defaultExpiration,
    this.maxSize,
  })  : assert(
          maxSize == null || maxSize > 0,
          'maxSize must be null or greater than 0',
        ),
        _persistentKey = persistentKey;

  final SharedPreferences prefs;
  final String _persistentKey;
  final Duration? defaultExpiration;
  final int? maxSize;

  JsonMap? _memoryCache;

  String get persistentKey => _persistentKey;

  DateTime? get _defaultExpirationDateTime =>
      defaultExpiration != null ? DateTime.now().add(defaultExpiration!) : null;

  @override
  Future<void> initialize() async => removeExpiredEntries();

  @override
  Future<void> dispose() async {}

  /// Get cached value wrapper from storage
  /// If key is null, returns the cached value stored under persistentKey
  /// If key is not null, returns the cached value stored under the given key
  Future<CachedValue<T>?> getCachedValue(String? key) async {
    final storage = _getStorage();
    final storageKey = key ?? _persistentKey;

    if (storage != null) {
      final valueJson = storage[storageKey] as JsonMap?;
      if (valueJson != null) {
        final cachedValue = CachedValue.fromJson<T>(valueJson, fromJson);
        developer.log(
          'Retrieved cached value for key "$storageKey"',
          name: 'PersistentStorageManager',
        );
        return cachedValue;
      } else {
        developer.log(
          'No cached value found for key "$storageKey"',
          name: 'PersistentStorageManager',
        );
      }
    }

    return null;
  }

  /// Get value from storage.
  /// If key is null, returns the value stored under persistentKey.
  /// If key is not null, returns the value stored under the given key.
  Future<T?> getValue({
    String? key,
    FutureOr<T> Function()? defaultValueProvider,
  }) async {
    final cachedValue = await getCachedValue(key);

    if (cachedValue != null) {
      if (!cachedValue.isExpired()) {
        return cachedValue.data;
      } else {
        developer.log(
          'Found expired value for key "${key ?? _persistentKey}"',
          name: 'PersistentStorageManager',
        );
      }
    }

    // If we get here, use default value provider
    if (defaultValueProvider != null) {
      developer.log(
        'Using default value provider for key "${key ?? _persistentKey}"',
        name: 'PersistentStorageManager',
      );
      final value = await defaultValueProvider();
      await setValue(value, key);
      return value;
    }

    developer.log(
      'No value found for key "${key ?? _persistentKey}" and no default value provider',
      name: 'PersistentStorageManager',
    );
    return null;
  }

  /// Get all values from storage
  Map<String, T>? getAllValues() {
    final storage = _getStorage();
    if (storage == null) {
      developer.log(
        'No storage found when getting all values',
        name: 'PersistentStorageManager',
      );
      return null;
    }

    final result = <String, T>{};
    for (final entry in storage.entries) {
      final cachedValue = CachedValue.fromJson<T>(
        entry.value as JsonMap,
        fromJson,
      );
      if (!cachedValue.isExpired()) {
        result[entry.key] = cachedValue.data;
      } else {
        developer.log(
          'Skipping expired value for key "${entry.key}" when getting all values',
          name: 'PersistentStorageManager',
        );
      }
    }

    if (result.isEmpty) {
      developer.log(
        'No valid values found when getting all values',
        name: 'PersistentStorageManager',
      );
      return null;
    }

    developer.log(
      'Retrieved ${result.length} valid values',
      name: 'PersistentStorageManager',
    );
    return result;
  }

  /// Set value in storage
  /// If key is null, stores under persistentKey
  /// If key is not null, stores under the given key
  Future<void> setValue(
    T value,
    String? key, {
    DateTime? expirationDateTime,
  }) async {
    expirationDateTime ??= _defaultExpirationDateTime;
    final storageKey = key ?? _persistentKey;

    final cachedValue = CachedValue(
      data: value,
      createdOn: DateTime.now(),
      expiration: expirationDateTime,
    );

    final storage = _getStorage() ?? {};
    storage[storageKey] = cachedValue.toJson(toJson);

    if (maxSize != null && key != null && storage.length > maxSize!) {
      developer.log(
        'Cache size exceeded maximum. Enforcing size limit of $maxSize',
        name: 'PersistentStorageManager',
      );
      _enforceCacheSize(storage);
    }

    _memoryCache = storage;
    await prefs.setString(_persistentKey, jsonEncode(storage));

    developer.log(
      'Stored value for key "$storageKey"${expirationDateTime != null ? " with expiration $expirationDateTime" : ""}',
      name: 'PersistentStorageManager',
    );
  }

  /// Remove value from storage
  /// If key is null, removes the value stored under persistentKey
  /// If key is not null, removes the value stored under the given key
  Future<void> remove({String? key}) async {
    final storage = _getStorage();
    if (storage != null) {
      final storageKey = key ?? _persistentKey;
      storage.remove(storageKey);

      _memoryCache = storage;
      await prefs.setString(_persistentKey, jsonEncode(storage));

      developer.log(
        'Removed value for key "$storageKey"',
        name: 'PersistentStorageManager',
      );
    }
  }

  /// Remove expired entries from storage
  Future<void> removeExpiredEntries() async {
    final storage = _getStorage();
    if (storage != null) {
      final initialSize = storage.length;

      storage.removeWhere(
        (key, value) {
          final isExpired = CachedValue.fromJson<dynamic>(
            value as JsonMap,
            (json) => json,
          ).isExpired();

          if (isExpired) {
            developer.log(
              'Removing expired value for key "$key"',
              name: 'PersistentStorageManager',
            );
          }
          return isExpired;
        },
      );

      if (initialSize != storage.length) {
        _memoryCache = storage;
        await prefs.setString(_persistentKey, jsonEncode(storage));

        developer.log(
          'Removed ${initialSize - storage.length} expired entries',
          name: 'PersistentStorageManager',
        );
      }
    }
  }

  JsonMap? _getStorage() {
    if (_memoryCache != null) {
      return _memoryCache;
    }

    final data = prefs.getString(_persistentKey);

    if (data != null) {
      return jsonDecode(data) as JsonMap;
    }

    return null;
  }

  void _enforceCacheSize(JsonMap storage) {
    final sortedEntries = storage.entries.toList()
      ..sort(
        (a, b) => CachedValue.fromJson<dynamic>(
          b.value as JsonMap,
          (json) => json,
        ).createdOn.compareTo(
              CachedValue.fromJson<dynamic>(
                a.value as JsonMap,
                (json) => json,
              ).createdOn,
            ),
      );

    storage
      ..clear()
      ..addEntries(sortedEntries.take(maxSize!));
  }

  /// Abstract method to convert json to type T
  T fromJson(dynamic json);

  /// Convert type T to JSON representation
  dynamic toJson(T value);
}
