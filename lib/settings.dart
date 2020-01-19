import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  String _home;
  bool value = true;

  void initState() {
    super.initState();
    _retrieveHome();
  }

  void dispose() {
    super.dispose();
  }

  Future<void> _retrieveHome() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _home = prefs.get("home");
    });
  }

  Future<void> _setHome(Position position) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("home", "${position.latitude},${position.longitude}");
    setState(() {
      _home = prefs.get("home");
    });
  }

  Future<void> _removeHome() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("home");
    setState(() {
      _home = prefs.get("home");
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Paramètres")),
        body: SettingsList(
          sections: [
            SettingsSection(
              title: 'Navigation',
              tiles: [
                SettingsTile(
                  title: 'Domicile',
                  subtitle: _home != null
                      ? _home
                      : "Appuyez ici pour définir la position actuelle comme votre domicile.",
                  leading: Icon(Icons.home),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Domicile"),
                            content: Text(
                                "Définir la position actuelle comme votre domicile?"),
                            actions: <Widget>[
                              FlatButton(
                                child: Text("REINITIALISER"),
                                onPressed: () {
                                  _removeHome();
                                  Navigator.of(context).pop();
                                },
                              ),
                              FlatButton(
                                child: Text("NON"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              FlatButton(
                                child: Text("OUI"),
                                onPressed: () {
                                  geolocator
                                      .getCurrentPosition(
                                          desiredAccuracy:
                                              LocationAccuracy.high)
                                      .then((Position position) {
                                    _setHome(position);
                                    Navigator.of(context).pop();
                                  });
                                },
                              ),
                            ],
                          );
                        });
                  },
                ),
              ],
            ),
          ],
        ));
  }
}
