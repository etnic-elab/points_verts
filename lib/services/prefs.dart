import 'package:shared_preferences/shared_preferences.dart';

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
  lastSelectedDate
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
    return prefs.remove('$key');
  }

  Future<String?> setString(Prefs key, String value) async {
    SharedPreferences prefs = await preferences;
    await prefs.setString('$key', value);
    return prefs.getString('$key');
  }

  Future<String?> getString(Prefs key) async {
    SharedPreferences prefs = await preferences;
    return prefs.getString('$key');
  }

  Future<int?> setInt(Prefs key, int value) async {
    SharedPreferences prefs = await preferences;
    await prefs.setInt('$key', value);
    return prefs.getInt('$key');
  }

  Future<int?> getInt(Prefs key) async {
    SharedPreferences prefs = await preferences;
    return prefs.getInt('$key');
  }

  Future<bool?> setBoolean(Prefs key, bool value) async {
    SharedPreferences prefs = await preferences;
    await prefs.setBool('$key', value);
    return prefs.getBool('$key');
  }

  Future<bool> getBoolean(Prefs key, {bool? defaultValue}) async {
    SharedPreferences prefs = await preferences;
    bool? result = prefs.getBool('$key');
    return result ?? defaultValue ?? false;
  }
}
