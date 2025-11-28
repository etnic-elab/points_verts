import 'dart:developer';
import 'dart:isolate';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:points_verts/firebase_options.dart';
import 'package:points_verts/services/prefs.dart';

const String _firebaseTag = "dev.alpagaga.points_verts.FirebaseLocalService";

class FirebaseLocalService {
  static FirebaseRemoteConfigService? firebaseRemoteConfigService;

  static Future<void> initialize({required bool isForeground}) async {
    // Step 1: Initialize Firebase (handle duplicate-app gracefully)
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        log(
          'Firebase initialized for isForeground: $isForeground',
          name: _firebaseTag,
        );
      } else {
        log(
          'Firebase already initialized, skipping initialization',
          name: _firebaseTag,
        );
      }
    } on FirebaseException catch (e) {
      if (e.code == 'duplicate-app') {
        log('Firebase duplicate-app caught, continuing...', name: _firebaseTag);
      } else {
        log('Firebase initialization error: $e', name: _firebaseTag);
        return;
      }
    } catch (err) {
      log(
        'Could not initialize firebase for isForeground: $isForeground, $err',
        name: _firebaseTag,
      );
      return;
    }

    // Step 2: Initialize dependent services (always runs if Firebase is available)
    try {
      CrashlyticsLocalService.initialize(isForeground);
      if (firebaseRemoteConfigService == null) {
        firebaseRemoteConfigService = FirebaseRemoteConfigService(
          firebaseRemoteConfig: FirebaseRemoteConfig.instance,
        );
        await firebaseRemoteConfigService!.init();
      }
    } catch (err) {
      log('Could not initialize Firebase services: $err', name: _firebaseTag);
    }
  }
}

const String _crashlyticsTag =
    "dev.alpagaga.points_verts.CrashlyticsLocalService";

class CrashlyticsLocalService {
  static void initialize(bool isForeground) {
    // Pass all uncaught errors from the framework to Crashlytics.
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    FirebaseCrashlytics.instance.setCustomKey('foreground', isForeground);
    FirebaseCrashlytics.instance.setCustomKey('test', false);
    FirebaseCrashlytics.instance.setCustomKey('debug', kDebugMode);
    _initializeOptIn();
    Isolate.current.addErrorListener(
      RawReceivePort((pair) async {
        final List<dynamic> errorAndStacktrace = pair;
        await FirebaseCrashlytics.instance.recordError(
          errorAndStacktrace.first,
          errorAndStacktrace.last,
        );
      }).sendPort,
    );
  }

  static Future<void> _initializeOptIn() async {
    bool enabled = await PrefsProvider.prefs.getBoolean(
      Prefs.crashlyticsEnabled,
    );
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(enabled);

    log(
      'Crashlytics is ${enabled ? 'enabled' : 'disabled'}',
      name: _crashlyticsTag,
    );
  }

  static Future<void> toggleCrashlyticsEnabled(bool enabled) async {
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(enabled);
    await PrefsProvider.prefs.setBoolean(Prefs.crashlyticsEnabled, enabled);

    log(
      'Crashlytics is now ${enabled ? 'enabled' : 'disabled'}',
      name: _crashlyticsTag,
    );
  }
}

class RemoteConfig {
  static String get numberOfTrips => 'number_of_trips';
  static String get walkData => 'walk_data';
}

class FirebaseRemoteConfigService {
  const FirebaseRemoteConfigService({required this.firebaseRemoteConfig});

  final FirebaseRemoteConfig firebaseRemoteConfig;

  Future<void> init() async {
    try {
      await firebaseRemoteConfig.ensureInitialized();
      await firebaseRemoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );

      await firebaseRemoteConfig.setDefaults(await _getDefaultValues());
      await firebaseRemoteConfig.fetchAndActivate();
    } on FirebaseException catch (e) {
      log('Unable to initialize Firebase Remote Config $e', name: _firebaseTag);
    }
  }

  Future<Map<String, dynamic>> _getDefaultValues() async {
    String walkData = await rootBundle
        .loadString('assets/walk_data.json')
        .catchError((e) => '');

    return {RemoteConfig.numberOfTrips: 5, RemoteConfig.walkData: walkData};
  }

  int getNumberOfTrips() =>
      firebaseRemoteConfig.getInt(RemoteConfig.numberOfTrips);
  String getJsonWalks() =>
      firebaseRemoteConfig.getString(RemoteConfig.walkData);
}
