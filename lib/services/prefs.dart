import 'package:shared_preferences/shared_preferences.dart';
import 'package:points_verts/extensions.dart';

enum Prefs {
  lastBackgroundFetch,
  lastWalkUpdate,
  showNotification,
  directoryWalkFilter,
  homeCoords,
  homeLabel,
  useLocation,
  firstLaunch,
  calendarWalkFilter,
  lastSelectedDate,
  news,
  lastNewsFetch,
  crashlyticsEnabled,
}

class PrefsProvider {
  PrefsProvider._();

  static final PrefsProvider prefs = PrefsProvider._();
  SharedPreferences? _sharedPreferences;

  Future<SharedPreferences> get preferences async {
    if (_sharedPreferences != null) {
      return _sharedPreferences as SharedPreferences;
    }
    _sharedPreferences = await SharedPreferences.getInstance();
    return _sharedPreferences as SharedPreferences;
  }

  Future<bool> remove(Prefs key) async {
    SharedPreferences prefs = await preferences;
    return prefs.remove(key.name);
  }

  Future<String?> setString(Prefs key, String value) async {
    SharedPreferences prefs = await preferences;
    await prefs.setString(key.name, value);
    return prefs.getString(key.name);
  }

  Future<String?> getString(Prefs key) async {
    SharedPreferences prefs = await preferences;
    return prefs.getString(key.name);
  }

  Future<int?> setInt(Prefs key, int value) async {
    SharedPreferences prefs = await preferences;
    await prefs.setInt(key.name, value);
    return prefs.getInt(key.name);
  }

  Future<int?> getInt(Prefs key) async {
    SharedPreferences prefs = await preferences;
    return prefs.getInt(key.name);
  }

  Future<bool?> setBoolean(Prefs key, bool value) async {
    SharedPreferences prefs = await preferences;
    await prefs.setBool(key.name, value);
    return prefs.getBool(key.name);
  }

  Future<bool?> getBoolean(Prefs key, {bool? defaultValue = false}) async {
    SharedPreferences prefs = await preferences;
    bool? result = prefs.getBool(key.name);
    return result ?? defaultValue;
  }
}
