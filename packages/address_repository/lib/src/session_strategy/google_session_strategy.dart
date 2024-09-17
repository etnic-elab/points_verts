import 'package:address_repository/src/session_strategy/session_strategy.dart';
import 'package:uuid/uuid.dart';

// Google Maps session strategy
class GoogleSessionStrategy implements SessionStrategy {
  GoogleSessionStrategy({int sessionTimeoutMinutes = 3})
      : _sessionTimeoutMinutes = sessionTimeoutMinutes,
        _uuid = const Uuid();

  final int _sessionTimeoutMinutes;
  final Uuid _uuid;
  String? _currentSessionToken;
  DateTime? _sessionStartTime;

  @override
  String? get currentSessionToken => _currentSessionToken;

  @override
  void ensureValidSession() {
    final now = DateTime.now();
    if (_currentSessionToken == null ||
        _sessionStartTime == null ||
        now.difference(_sessionStartTime!).inMinutes >=
            _sessionTimeoutMinutes) {
      _currentSessionToken = _uuid.v4();
      _sessionStartTime = now;
    }
  }

  @override
  void endSession() {
    _currentSessionToken = null;
    _sessionStartTime = null;
  }
}
