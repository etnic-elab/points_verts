import 'dart:developer';
import 'dart:isolate';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:points_verts/firebase_options.dart';
import 'package:points_verts/services/prefs.dart';

const String _firebaseTag = "dev.alpagaga.points_verts.FirebaseLocalService";

class FirebaseLocalService {
  static initialize({required bool isForeground}) async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      CrashlyticsLocalService.initialize(isForeground);
      log('Firebase initialized for isForeground: $isForeground',
          name: _firebaseTag);
    } catch (err) {
      log('Could not initilaze firebase for isForeground: $isForeground, $err',
          name: _firebaseTag);
    }
  }
}

const String _crashlyticsTag =
    "dev.alpagaga.points_verts.CrashlyticsLocalService";

class CrashlyticsLocalService {
  static initialize(bool isForeground) {
    // Pass all uncaught errors from the framework to Crashlytics.
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    FirebaseCrashlytics.instance.setCustomKey('foreground', isForeground);
    FirebaseCrashlytics.instance.setCustomKey('test', false);
    FirebaseCrashlytics.instance.setCustomKey('debug', !kReleaseMode);
    _initializeOptIn();
    Isolate.current.addErrorListener(RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      await FirebaseCrashlytics.instance.recordError(
        errorAndStacktrace.first,
        errorAndStacktrace.last,
      );
    }).sendPort);
  }

  static Future<void> _initializeOptIn() async {
    bool enabled =
        await PrefsProvider.prefs.getBoolean(Prefs.crashlyticsEnabled);
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(enabled);

    log('Crashlytics is ${enabled ? 'enabled' : 'disabled'}',
        name: _crashlyticsTag);
  }

  static Future<void> toggleCrashlyticsEnabled(bool enabled) async {
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(enabled);
    await PrefsProvider.prefs.setBoolean(Prefs.crashlyticsEnabled, enabled);

    log('Crashlytics is now ${enabled ? 'enabled' : 'disabled'}',
        name: _crashlyticsTag);
  }
}
