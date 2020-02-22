import 'package:shared_preferences/shared_preferences.dart';

class PrefsProvider {
  PrefsProvider._();

  static final PrefsProvider prefs = PrefsProvider._();
  SharedPreferences _sharedPreferences;

  Future<SharedPreferences> get preferences async {
    if (_sharedPreferences != null) return _sharedPreferences;
    _sharedPreferences = await SharedPreferences.getInstance();
    return _sharedPreferences;
  }

  Future<String> setString(String key, String value) async {
    SharedPreferences prefs = await preferences;
    await prefs.setString(key, value);
    return prefs.getString(key);
  }

  Future<String> getString(String key) async {
    SharedPreferences prefs = await preferences;
    return prefs.getString(key);
  }
}
