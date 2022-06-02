import 'dart:developer';
import 'dart:io';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:package_info/package_info.dart';
import 'package:points_verts/environment.dart';
import 'package:points_verts/services/assets.dart';
import 'package:points_verts/services/background_fetch.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:points_verts/views/walks/walk_utils.dart';

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

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await dotenv.load();
  await _deleteData();
  await _addTrustedCert(Assets.letsEncryptCert);
  runApp(const MyApp());
  BackgroundFetch.registerHeadlessTask(BackgroundFetchProvider.headlessTask);
}

Future _deleteData() async {
  if (Environment.deleteData) {
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
          Prefs.lastSelectedDate
        ]),
        PrefsProvider.prefs
            .setString(Prefs.lastDataDeleteBuild, packageInfo.buildNumber)
      ]);
      log("Local data deleted for buildNumber: ${packageInfo.buildNumber}");
    }
  }
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
      updateWalks();
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
      theme: CompanyTheme.companyLightTheme(),
      darkTheme: CompanyTheme.companyDarkTheme(),
      home: const WalksHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
