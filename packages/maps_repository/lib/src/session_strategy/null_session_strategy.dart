// Null session strategy for APIs that don't require session management
import 'package:maps_repository/src/session_strategy/session_strategy.dart';

class NullSessionStrategy implements SessionStrategy {
  @override
  String? get currentSessionToken => null;

  @override
  void ensureValidSession() {}

  @override
  void endSession() {}
}
