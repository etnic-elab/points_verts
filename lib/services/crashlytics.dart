import 'dart:developer';

import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'prefs.dart';

const String tag = "dev.alpagaga.points_verts.Crashlytics";

class Crashlytics {
  static Future<bool?> crashlyticsPrompt(BuildContext context) async {
    bool? result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('Diagnostic'),
              content: const Text(
                  "L'envoi automatique de données de diagnostic nous permet d'améliorer l'application."),
              actions: <Widget>[
                TextButton(
                  child: const Text('Autoriser'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                TextButton(
                  child: const Text('Refuser'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ]);
        });
    if (result != null) toggleCollectionEnabled(result);
  }

  static Future<void> initialize(BuildContext context) async {
    bool? enabled = await PrefsProvider.prefs
        .getBoolean(Prefs.crashlyticsEnabled, defaultValue: null);

    enabled == null
        ? crashlyticsPrompt(context)
        : setCollectionEnabled(enabled);
  }

  static void toggleCollectionEnabled(bool value) {
    PrefsProvider.prefs.setBoolean(Prefs.crashlyticsEnabled, value);
    setCollectionEnabled(value);
  }

  static Future<void> setCollectionEnabled(bool value) async {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(value);
    log("Crashlytics is now " + (value ? "enabled" : "disabled"), name: tag);
  }
}
