import 'package:get_it/get_it.dart';
import 'package:points_verts/abstractions/environment.dart';
import 'package:points_verts/services/database.dart';
import 'package:points_verts/services/navigation.dart';
import 'package:points_verts/services/notification.dart';
import 'package:points_verts/services/prefs.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => PrefsProvider());
  locator.registerLazySingleton(() => Environment());
  locator.registerLazySingleton(() => NotificationManager());
  locator.registerLazySingleton(() => DBProvider());
  locator.registerLazySingleton(() => NavigationService());
}
