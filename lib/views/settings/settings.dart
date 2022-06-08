import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:points_verts/company_data.dart';
import 'package:points_verts/services/firebase.dart';
import 'package:points_verts/services/location.dart';
import 'package:points_verts/views/list_header.dart';
import 'package:points_verts/services/notification.dart';
import 'package:points_verts/views/walks/walk_utils.dart';

import '../../models/address_suggestion.dart';
import '../../services/notification.dart';
import '../../services/prefs.dart';
import '../tile_icon.dart';
import 'about.dart';
import 'debug.dart';
import 'settings_home_select.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String? _home;
  bool _useLocation = false;
  bool _showNotification = false;
  bool _crashlyticsEnabled = false;

  _SettingsState();

  @override
  void initState() {
    super.initState();
    _retrievePrefs();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _retrievePrefs() async {
    final futures = await Future.wait([
      PrefsProvider.prefs.getString(Prefs.homeLabel),
      PrefsProvider.prefs.getBoolean(Prefs.useLocation),
      PrefsProvider.prefs.getBoolean(Prefs.showNotification),
      PrefsProvider.prefs.getBoolean(Prefs.crashlyticsEnabled)
    ]);
    setState(() {
      _home = futures[0] as String?;
      _useLocation = futures[1] as bool;
      _showNotification = futures[2] as bool;
      _crashlyticsEnabled = futures[3] as bool;
    });
  }

  Future<void> _setHome(AddressSuggestion suggestion) async {
    await PrefsProvider.prefs.setString(
        Prefs.homeCoords, "${suggestion.latitude},${suggestion.longitude}");
    String? label = await PrefsProvider.prefs
        .setString(Prefs.homeLabel, suggestion.address);
    setState(() {
      _home = label;
    });
    if (_showNotification == true) {
      NotificationManager.instance.scheduleNextNearestWalkNotifications();
    }
  }

  Future<void> _removeHome() async {
    await PrefsProvider.prefs.remove(Prefs.homeCoords);
    await PrefsProvider.prefs.remove(Prefs.homeLabel);
    setState(() {
      _home = null;
    });
    NotificationManager.instance.cancelNextNearestWalkNotifications();
  }

  Future<void> _setUseLocation(bool newValue) async {
    bool validated = true;
    if (newValue == true) {
      LocationPermission permission = await checkLocationPermission();
      validated = permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    }

    if (validated) {
      await PrefsProvider.prefs.setBoolean(Prefs.useLocation, newValue);
      setState(() {
        _useLocation = newValue;
      });
    }
  }

  void _setCrashlyticsEnabled(bool isEnabled) async {
    bool wasEnabled = _crashlyticsEnabled;
    isEnabled =
        await CrashlyticsLocalService.toggleCrashlyticsEnabled(isEnabled);

    setState(() => _crashlyticsEnabled = isEnabled);
    if (wasEnabled && !isEnabled) {
      crashlyticsNewOptOutDialog();
    }
  }

  Future<void> _setShowNotification(bool newValue) async {
    await PrefsProvider.prefs.setBoolean(Prefs.showNotification, newValue);
    if (newValue == false) {
      NotificationManager.instance.cancelNextNearestWalkNotifications();
    } else {
      bool? notificationsAllowed =
          await NotificationManager.instance.requestNotificationPermissions();
      if (notificationsAllowed == false) return _setShowNotification(false);

      NotificationManager.instance.scheduleNextNearestWalkNotifications();
      if (Platform.isIOS && mounted) _showIOSNotificationAlert();
    }
    setState(() {
      _showNotification = newValue;
    });
  }

  void _showIOSNotificationAlert() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Attention'),
          content: const Text('''
iOS empêche les applications peu utilisées d'exécuter des tâches en arrière-plan régulièrement, ce dont l'application a besoin pour planifier les notifications.
Nous vous conseillons d'ouvrir l'application au moins une fois par semaine pour contourner cette restriction.
'''),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
            child: const Text("Paramètres"),
            onLongPress: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => const Debug()))),
      ),
      body: ListView(
        children: <Widget>[
          const ListHeader("Tri des points selon leur emplacement"),
          ListTile(
              title: Text(
                  "Autorisez l'accès à votre position et/ou indiquez votre domicile pour que l'application affiche en premier les points les plus proches dans la vue 'Calendrier'.",
                  style: Theme.of(context).textTheme.caption)),
          SwitchListTile(
            secondary: const TileIcon(Icon(Icons.location_on)),
            title: const Text("Ma position actuelle"),
            value: _useLocation,
            onChanged: (bool value) {
              _setUseLocation(value);
            },
          ),
          ListTile(
            leading: const TileIcon(Icon(Icons.home)),
            title: const Text('Mon domicile'),
            subtitle: getHomeLabel(),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      SettingsHomeSelect(_setHome, _removeHome)));
            },
            trailing: _home != null
                ? IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeHome())
                : null,
          ),
          const Divider(),
          const ListHeader("Notifications"),
          ListTile(
              title: Text(
                  "L'application peut afficher une notification indiquant le point le plus proche de votre domicile, si ce dernier est définit.",
                  style: Theme.of(context).textTheme.caption)),
          SwitchListTile(
            secondary: const TileIcon(Icon(Icons.notifications)),
            title: const Text("Notifier la veille (vers 20h)"),
            value: _showNotification,
            onChanged: (bool value) {
              _setShowNotification(value);
            },
          ),
          const Divider(),
          const ListHeader("Diagnostic"),
          ListTile(
            title: Text(
                "L'envoi automatique de données de diagnostic nous permet d'améliorer l'application.",
                style: Theme.of(context).textTheme.caption),
          ),
          SwitchListTile(
            secondary: const TileIcon(Icon(Icons.bug_report)),
            title: const Text("Envoi de rapports"),
            value: _crashlyticsEnabled,
            onChanged: (bool value) {
              _setCrashlyticsEnabled(value);
            },
          ),
          const Divider(),
          ListTile(
            leading: const TileIcon(Icon(Icons.help)),
            title: const Text("Assistance"),
            onTap: () => launchURL(assistanceUrl),
          ),
          ListTile(
            leading: const TileIcon(Icon(Icons.security)),
            title: const Text("Charte de la vie privée"),
            onTap: () => launchURL(privacyUrl),
          ),
          const About()
        ],
      ),
    );
  }

  Widget getHomeLabel() {
    if (_home == null) {
      return const Text("Aucun - appuyez ici pour le définir");
    } else {
      return Text(_home!, style: const TextStyle(fontSize: 12.0));
    }
  }

  Future<void> crashlyticsNewOptOutDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('Diagnostic'),
              content: const Text(
                  "L'envoi automatique de données de diagnostic sera désactivé dès la prochaine fermeture de l'application."),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ]);
        });
  }
}
