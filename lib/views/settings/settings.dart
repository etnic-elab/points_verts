import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:points_verts/views/list_header.dart';

import '../../models/address_suggestion.dart';
import '../../services/prefs.dart';
import 'settings_home_select.dart';

class Settings extends StatefulWidget {
  Settings({this.callback});

  final Function callback;

  @override
  State<StatefulWidget> createState() => _SettingsState(callback: callback);
}

class _SettingsState extends State<Settings> {
  final Geolocator geoLocator = Geolocator()..forceAndroidLocationManager;
  String _home;
  String _theme;
  bool _useLocation = false;
  bool _showNotification = false;

  _SettingsState({this.callback});

  Function callback;

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
    bool useLocation =
        await PrefsProvider.prefs.getBoolean(key: "use_location");
    bool showNotification = await PrefsProvider.prefs
        .getBoolean(key: "show_notification", defaultValue: true);
    setState(() {
      _theme = theme;
      _home = home;
      _useLocation = useLocation;
      _showNotification = showNotification;
    });
  }

  Future<void> _setHome(AddressSuggestion suggestion) async {
    await PrefsProvider.prefs.setString(
        "home_coords", "${suggestion.latitude},${suggestion.longitude}");
    String label =
        await PrefsProvider.prefs.setString("home_label", suggestion.address);
    setState(() {
      _home = label;
    });
    if (callback != null) {
      callback();
    }
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
    if (callback != null) {
      callback();
    }
  }

  Future<void> _setUseLocation(bool newValue) async {
    bool validated = false;
    if (newValue == true) {
      validated = await checkLocationPermission() == PermissionStatus.granted;
    } else {
      validated = true;
    }
    if (validated) {
      await PrefsProvider.prefs.setBoolean("use_location", newValue);
      setState(() {
        _useLocation = newValue;
      });
      if (callback != null) {
        callback();
      }
    }
  }

  Future<void> _setShowNotification(bool newValue) async {
    await PrefsProvider.prefs.setBoolean("show_notification", newValue);
    setState(() {
      _showNotification = newValue;
    });
  }

  Future<PermissionStatus> checkLocationPermission() async {
    PermissionGroup group = PermissionGroup.locationWhenInUse;
    PermissionHandler permissionHandler = PermissionHandler();
    PermissionStatus permission =
        await permissionHandler.checkPermissionStatus(group);
    print("PermissionStatus is $permission");
    switch (permission) {
      case PermissionStatus.neverAskAgain:
        await permissionHandler.openAppSettings();
        break;
      case PermissionStatus.denied:
        Map<PermissionGroup, PermissionStatus> results =
            await permissionHandler.requestPermissions([group]);
        return results[group];
    }
    return permission;
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
    return ListView(
      children: <Widget>[
        ListTile(
          leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[Icon(Icons.palette)]),
          title: Text('Thème'),
          subtitle: Text(_defineThemeSubtitle()),
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
                                  style: Theme.of(context).textTheme.caption)),
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
        ),
        ListHeader("Tri des points selon leur emplacement"),
        ListTile(
            title: Text(
                "Autorisez l'accès à votre position et/ou indiquez votre domicile pour que l'application affiche en premier les points les plus proches.",
                style: Theme.of(context).textTheme.caption)),
        Divider(height: 0.5),
        SwitchListTile(
          secondary: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[Icon(Icons.location_on)]),
          title: Text("Ma position actuelle"),
          value: _useLocation,
          onChanged: (bool value) {
            _setUseLocation(value);
          },
        ),
        Divider(height: 0.5),
        ListTile(
          leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[Icon(Icons.home)]),
          title: Text('Mon domicile'),
          subtitle: Text(
              _home != null
                  ? "${_home.substring(0, min(50, _home.length))}..."
                  : "Aucun - appuyez ici pour le définir",
              style: Theme.of(context).textTheme.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    SettingsHomeSelect(_setHome, _removeHome)));
          },
        ),
        ListHeader("Notifications"),
        ListTile(
            title: Text(
                "L'application peut afficher une notification indiquant le point le plus proche de votre domicile, si ce dernier est définit.",
                style: Theme.of(context).textTheme.caption)),
        Divider(height: 0.5),
        SwitchListTile(
          secondary: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[Icon(Icons.notifications)]),
          title: Text("Notifier la veille (vers 20h)"),
          value: _showNotification,
          onChanged: (bool value) {
            _setShowNotification(value);
          },
        ),
      ],
    );
  }
}
