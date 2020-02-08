import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:settings_ui/settings_ui.dart';

import 'app_drawer.dart';
import 'mapbox_suggestion.dart';
import 'prefs.dart';
import 'settings_home_select.dart';

class Settings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  String _home;
  String _theme;
  bool value = true;

  void initState() {
    super.initState();
    _retrievePrefs();
  }

  void dispose() {
    super.dispose();
  }

  Future<void> _retrievePrefs() async {
    String theme = await PrefsProvider.prefs.getString("theme");
    String home = await PrefsProvider.prefs.getString("home_label");
    setState(() {
      _theme = theme;
      _home = home;
    });
  }

  Future<void> _setHome(MapBoxSuggestion suggestion) async {
    await PrefsProvider.prefs.setString(
        "home_coords", "${suggestion.latitude},${suggestion.longitude}");
    String label =
        await PrefsProvider.prefs.setString("home_label", suggestion.address);
    setState(() {
      _home = label;
    });
  }

  Future<void> _setTheme(String newTheme) async {
    String theme = await PrefsProvider.prefs.setString("theme", newTheme);
    setState(() {
      _theme = theme;
    });
  }

  Future<void> _removeHome() async {
    await PrefsProvider.prefs.setString("home_coords", null);
    await PrefsProvider.prefs.setString("home_label", null);
    setState(() {
      _home = null;
    });
  }

  String _defineThemeSubtitle() {
    if (_theme == "light") {
      return "Clair";
    } else if (_theme == "dark") {
      return "Sombre";
    } else {
      return "Automatique";
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Paramètres")),
        drawer: AppDrawer(),
        body: SettingsList(
          sections: [
            SettingsSection(title: 'Affichage', tiles: [
              SettingsTile(
                title: 'Thème',
                leading: Icon(Icons.palette),
                subtitle: _defineThemeSubtitle(),
                onTap: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        contentPadding: EdgeInsets.only(top: 12),
                        title: Text("Thème"),
                        content: SingleChildScrollView(child: StatefulBuilder(
                          builder: (context, setState) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Divider(),
                                ListTile(
                                    leading: Icon(Icons.info),
                                    title: Text(
                                        "Tout changement de thème nécessite un redémarrage de l'application.",
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption)),
                                Divider(),
                                RadioListTile(
                                  title: Text("Automatique"),
                                  subtitle: Text("Laisse le système décider"),
                                  value: null,
                                  groupValue: _theme,
                                  onChanged: (String value) {
                                    _setTheme(value);
                                    Navigator.of(context).pop();
                                  },
                                ),
                                RadioListTile(
                                  title: Text("Clair"),
                                  subtitle: Text("Force le mode clair"),
                                  value: "light",
                                  groupValue: _theme,
                                  onChanged: (String value) {
                                    _setTheme(value);
                                    Navigator.of(context).pop();
                                  },
                                ),
                                RadioListTile(
                                  title: Text("Sombre"),
                                  subtitle: Text("Force le mode sombre"),
                                  value: "dark",
                                  groupValue: _theme,
                                  onChanged: (String value) {
                                    _setTheme(value);
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          },
                        )),
                        actions: [
                          FlatButton(
                            child: Text('ANNULER'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      );
                    },
                  );
                },
              )
            ]),
            SettingsSection(
              title: 'Navigation',
              tiles: [
                SettingsTile(
                  title: 'Domicile',
                  subtitle: _home != null ? _home : "Aucun - appuyez ici pour le définir",
                  leading: Icon(Icons.home),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SettingsHomeSelect(_setHome, _removeHome)));
                  },
                ),
              ],
            ),
          ],
        ));
  }
}
