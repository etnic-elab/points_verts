import 'package:shared_preferences/shared_preferences.dart';

class PrefsProvider {
  PrefsProvider() {
    _sharedPreferences = SharedPreferences.getInstance();
  }
  late final Future<SharedPreferences> _sharedPreferences;

  Future<SharedPreferences> get preferences => _sharedPreferences;

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

  Future<bool> getBoolean(Prefs key, {bool? defaultValue}) async {
    SharedPreferences prefs = await preferences;
    bool? result = prefs.getBool(key.name);
    return result ?? defaultValue ?? false;
  }
}

enum Prefs {
  lastBackgroundFetch,
  lastWalkUpdate,
  showNotification,
  calendarWalkFilter,
  directoryWalkFilter,
  homeCoords,
  homeLabel,
  firstLaunch,
  lastSelectedDate,
  calendarSortBy,
  directorySortBy,
}

extension PrefsExt on Prefs {
  String get name {
    switch (this) {
      case Prefs.lastBackgroundFetch:
        return 'last_background_fetch';
      case Prefs.lastWalkUpdate:
        return 'last_walk_update';
      case Prefs.showNotification:
        return 'show_notification';
      case Prefs.directoryWalkFilter:
        return 'directory_walk_filter';
      case Prefs.homeCoords:
        return 'home_coords';
      case Prefs.homeLabel:
        return 'home_label';
      case Prefs.firstLaunch:
        return 'first_launch';
      case Prefs.calendarWalkFilter:
        return 'calendar_walk_filter';
      case Prefs.lastSelectedDate:
        return 'last_selected_date';
      case Prefs.calendarSortBy:
        return 'calendar_sort_by';
      case Prefs.directorySortBy:
        return 'directory_sort_by';
    }
  }
}
