import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:points_verts/constants.dart';
import 'package:points_verts/services/assets.dart';
import 'package:points_verts/services/background_fetch.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:points_verts/views/walks/walk_utils.dart';
import 'package:points_verts/services/firebase.dart';

import 'package:points_verts/walks_home_screen.dart';
import 'package:points_verts/company_data.dart';

Future<void> _addTrustedCert(String certPath) async {
  ByteData data = await Assets.asset.load(certPath);
  SecurityContext context = SecurityContext.defaultContext;
  try {
    context.setTrustedCertificatesBytes(data.buffer.asUint8List());
  } catch (err) {
    print("Cannot add certificate: $err");
  }
}

Future _deleteData() async {
  List futures = await Future.wait([
    PackageInfo.fromPlatform(),
    PrefsProvider.prefs.getString(Prefs.lastDataDeleteBuild)
  ]);
  PackageInfo packageInfo = futures[0];
  String? lastDataDeleteBuild = futures[1];

  if (packageInfo.buildNumber != lastDataDeleteBuild) {
    await Future.wait([
      PrefsProvider.prefs.removeAll(remove: [
        Prefs.lastWalkUpdate,
        Prefs.news,
        Prefs.lastNewsFetch,
      ]),
      PrefsProvider.prefs
          .setString(Prefs.lastDataDeleteBuild, packageInfo.buildNumber)
    ]);
    log("Local data deleted for buildNumber: ${packageInfo.buildNumber}");
  }
}

void main() async {
  runZonedGuarded<Future<void>>(() async {
    await dotenv.load();
    await FirebaseLocalService.initialize(isForeground: true);
    await Future.wait([
      if (kDeleteData) _deleteData(),
      _addTrustedCert(Assets.letsEncryptCert)
    ]);
    runApp(const MyApp());
    BackgroundFetch.registerHeadlessTask(BackgroundFetchProvider.headlessTask);
  },
      (error, stack) =>
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true));
}

class MyApp extends StatefulWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();

  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      try {
        updateWalks();
      } catch (err) {
        print('updateWalks on resuming foreground gave error: $err');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('fr', 'BE'),
        Locale('fr', 'FR'),
        Locale('fr', 'LU'),
      ],
      navigatorKey: MyApp.navigatorKey,
      title: applicationName,
      theme: CompanyTheme.companyLight,
      darkTheme: CompanyTheme.companyDark,
      home: const WalksHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
