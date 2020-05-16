import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:points_verts/views/list_header.dart';

import '../../models/address_suggestion.dart';
import '../../services/prefs.dart';
import '../tile_icon.dart';
import 'about.dart';
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
    String home = await PrefsProvider.prefs.getString("home_label");
    bool useLocation =
        await PrefsProvider.prefs.getBoolean(key: "use_location");
    bool showNotification = await PrefsProvider.prefs
        .getBoolean(key: "show_notification", defaultValue: true);
    setState(() {
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
    callback(resetDate: false);
  }

  Future<void> _removeHome() async {
    await PrefsProvider.prefs.setString("home_coords", null);
    await PrefsProvider.prefs.setString("home_label", null);
    setState(() {
      _home = null;
    });
    callback(resetDate: false);
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
      callback(resetDate: false);
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

  Widget _header(String title) {
    return Container(
      child: Text(title, style: Theme.of(context).textTheme.subtitle1),
      padding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 5.0),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Paramètres"),
        actions: <Widget>[About()],
      ),
      body: ListView(
        children: <Widget>[
          _header("Tri des points selon leur emplacement"),
          ListTile(
              title: Text(
                  "Autorisez l'accès à votre position et/ou indiquez votre domicile pour que l'application affiche en premier les points les plus proches.",
                  style: Theme.of(context).textTheme.caption)),
          SwitchListTile(
            secondary: TileIcon(Icon(Icons.location_on)),
            title: Text("Ma position actuelle"),
            value: _useLocation,
            onChanged: (bool value) {
              _setUseLocation(value);
            },
          ),
          ListTile(
            leading: TileIcon(Icon(Icons.home)),
            title: Text('Mon domicile'),
            subtitle: Text(
                _home != null ? _home : "Aucun - appuyez ici pour le définir",
                overflow: TextOverflow.ellipsis),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      SettingsHomeSelect(_setHome, _removeHome)));
            },
          ),
          _header("Notifications"),
          ListTile(
              title: Text(
                  "L'application peut afficher une notification indiquant le point le plus proche de votre domicile, si ce dernier est définit.",
                  style: Theme.of(context).textTheme.caption)),
          SwitchListTile(
            secondary: TileIcon(Icon(Icons.notifications)),
            title: Text("Notifier la veille (vers 20h)"),
            value: _showNotification,
            onChanged: (bool value) {
              _setShowNotification(value);
            },
          ),
        ],
      ),
    );
  }
}
