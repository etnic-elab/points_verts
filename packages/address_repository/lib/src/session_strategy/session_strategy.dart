export 'google_session_strategy.dart';
export 'null_session_strategy.dart';

// Session management strategy interface
abstract class SessionStrategy {
  String? get currentSessionToken;
  void ensureValidSession();
  void endSession();
}
