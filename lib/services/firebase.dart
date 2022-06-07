import 'dart:developer';
import 'dart:isolate';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:points_verts/constants.dart';
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
  static bool debugEnabled = kDebugCrashlytics && !kReleaseMode;

  static initialize(bool isForeground) {
    // Pass all uncaught errors from the framework to Crashlytics.
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    FirebaseCrashlytics.instance.setCustomKey('foreground', isForeground);
    FirebaseCrashlytics.instance.setCustomKey('test', false);
    FirebaseCrashlytics.instance.setCustomKey('debug', false);
    _initializeOptIn();
    Isolate.current.addErrorListener(RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      await FirebaseCrashlytics.instance.recordError(
        errorAndStacktrace.first,
        errorAndStacktrace.last,
      );
    }).sendPort);
  }

  static Future<bool> _initializeOptIn() async {
    if (debugEnabled) {
      FirebaseCrashlytics.instance.setCustomKey('debug', true);
      FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      await PrefsProvider.prefs.setBoolean(Prefs.crashlyticsEnabled, true);
      log("Crashlytics is enabled in debug mode", name: _crashlyticsTag);
      return true;
    }

    bool enabled = kReleaseMode &&
        await PrefsProvider.prefs.getBoolean(Prefs.crashlyticsEnabled);
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(enabled);

    log('Crashlytics is ${enabled ? 'enabled' : 'disabled'}, kReleaseMode: $kReleaseMode',
        name: _crashlyticsTag);

    return enabled;
  }

  static Future<bool> toggleCrashlyticsEnabled(bool newValue) async {
    bool? enabled;
    if ((debugEnabled || kReleaseMode) == false && newValue == true) {
      log('Could not enable Crashlytics because you run in debug mode. To enable in debug mode, set kDebugCrashlytics to true',
          name: _crashlyticsTag);
      enabled = false;
    } else {
      enabled = newValue && debugEnabled || kReleaseMode;
    }

    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(enabled);
    await PrefsProvider.prefs.setBoolean(Prefs.crashlyticsEnabled, enabled);

    log('Crashlytics is now ${enabled ? 'enabled' : 'disabled'}. debugEnabled: $debugEnabled, kReleaseMode: $kReleaseMode',
        name: _crashlyticsTag);

    return enabled;
  }
}
