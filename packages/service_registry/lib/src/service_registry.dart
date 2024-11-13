import 'package:meta/meta.dart' show protected;
import 'package:service_registry/service_registry.dart' show Service;

/// Base registry that enforces singleton pattern for all implementations
abstract class ServiceRegistry {
  // Protected constructor that can only be used by implementations
  @protected
  ServiceRegistry();

  // Force implementations to define a static instance
  static ServiceRegistry get instance => throw UnimplementedError(
        'Implementations must override the static instance getter',
      );

  final _services = <Type, Service>{};
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  @protected
  void registerService<T extends Service>(T service) {
    _services[T] = service;
  }

  T get<T extends Service>() {
    checkInitialized();

    final service = _services[T];
    if (service == null) {
      throw Exception('Service not found: $T');
    }
    return service as T;
  }

  Future<void> initialize() async {
    if (_isInitialized) {
      throw StateError('ServiceRegistry is already initialized');
    }

    for (final service in _services.values) {
      await service.initialize();
    }

    _isInitialized = true;
  }

  Future<void> dispose() async {
    for (final service in _services.values) {
      await service.dispose();
    }
    _services.clear();
    _isInitialized = false;
  }

  void checkInitialized() {
    if (!_isInitialized) {
      throw StateError('Must initialize registry first');
    }
  }
}
