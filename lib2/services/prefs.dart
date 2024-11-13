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
  lastSelectedDate,
  news,
  lastNewsFetch,
  lastDataDeleteBuild,
  crashlyticsEnabled,
}

extension PrefsX on Prefs {
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
      case Prefs.useLocation:
        return 'use_location';
      case Prefs.firstLaunch:
        return 'first_launch';
      case Prefs.calendarWalkFilter:
        return 'calendar_walk_filter';
      case Prefs.lastSelectedDate:
        return 'last_selected_date';
      case Prefs.news:
        return 'news';
      case Prefs.lastNewsFetch:
        return 'last_news_fetch';
      case Prefs.lastDataDeleteBuild:
        return 'last_data_delete_build';
      case Prefs.crashlyticsEnabled:
        return 'crashlytics_enabled';
    }
  }
}

class PrefsProvider {
  PrefsProvider._();

  static final PrefsProvider prefs = PrefsProvider._();
  Future<SharedPreferences>? _sharedPreferences;

  Future<SharedPreferences> get preferences =>
      _sharedPreferences ??= SharedPreferences.getInstance();

  Future<bool> remove(Prefs key) async {
    final prefs = await preferences;
    return prefs.remove(key.name);
  }

  Future<List<bool>> removeAll({List<Prefs>? remove}) async {
    remove = remove ?? Prefs.values;
    return Future.wait(remove.map(prefs.remove));
  }

  Future<String?> setString(Prefs key, String value) async {
    final prefs = await preferences;
    await prefs.setString(key.name, value);
    return prefs.getString(key.name);
  }

  Future<String?> getString(Prefs key) async {
    final prefs = await preferences;
    return prefs.getString(key.name);
  }

  Future<int?> setInt(Prefs key, int value) async {
    final prefs = await preferences;
    await prefs.setInt(key.name, value);
    return prefs.getInt(key.name);
  }

  Future<int?> getInt(Prefs key) async {
    final prefs = await preferences;
    return prefs.getInt(key.name);
  }

  Future<bool?> setBoolean(Prefs key, bool value) async {
    final prefs = await preferences;
    await prefs.setBool(key.name, value);
    return prefs.getBool(key.name);
  }

  Future<bool> getBoolean(Prefs key, {bool defaultValue = false}) async {
    return await getBooleanNullable(key) ?? defaultValue;
  }

  Future<bool?> getBooleanNullable(Prefs key) async {
    final prefs = await preferences;
    final bool? result = prefs.getBool(key.name);
    return result;
  }
}
