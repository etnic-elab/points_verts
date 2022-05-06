import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:points_verts/services/environment.dart';
import 'package:points_verts/services/database.dart';
import 'package:points_verts/services/navigation.dart';
import 'package:points_verts/services/notification.dart';
import 'package:points_verts/services/prefs.dart';

GetIt locator = GetIt.instance;
PrefsProvider prefs = locator<PrefsProvider>();
Environment env = locator<Environment>();
NotificationManager notification = locator<NotificationManager>();
DBProvider db = locator<DBProvider>();
NavigatorState navigator = locator<NavigationService>().navigate;

void setupLocator() {
  locator.registerLazySingleton(() => PrefsProvider());
  locator.registerLazySingleton(() => Environment());
  locator.registerLazySingleton(() => NotificationManager());
  locator.registerLazySingleton(() => DBProvider());
  locator.registerLazySingleton(() => NavigationService());
}
