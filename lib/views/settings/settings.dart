import 'dart:io';

import 'package:flutter/material.dart';
import 'package:points_verts/abstractions/company_data.dart';
import 'package:points_verts/models/view_type.dart';
import 'package:points_verts/services/home.dart';
import 'package:points_verts/services/navigation.dart';
import 'package:points_verts/services/service_locator.dart';
import 'package:points_verts/views/walks/utils.dart';
import 'package:points_verts/views/widgets/app_drawer.dart';
import 'package:points_verts/views/widgets/list_header.dart';

import '../../models/address_suggestion.dart';
import '../../services/prefs.dart';
import '../widgets/centered_tile_icon.dart';
import 'about.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String? _home;
  bool _showNotification = false;

  _SettingsState();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initData() async {
    List futures = await Future.wait([
      prefs.getString(Prefs.homeLabel),
      prefs.getBoolean(Prefs.showNotification, defaultValue: false)
    ]);
    setState(() {
      _home = futures[0];
      _showNotification = futures[1];
    });
  }

  Future<void> _setShowNotification(bool newValue) async {
    await prefs.setBoolean(Prefs.showNotification, newValue);
    if (newValue == true) {
      bool? notificationsAllowed =
          await notification.requestNotificationPermissions();
      if (notificationsAllowed == false) return _setShowNotification(false);

      notification.scheduleNextNearestWalkNotifications();
      if (Platform.isIOS) _showIOSNotificationAlert;
    } else {
      notification.cancelNextNearestWalkNotifications();
    }
    setState(() {
      _showNotification = newValue;
    });
  }

  Widget get _homeLabel {
    return _home == null
        ? const Text("Aucun - appuyez ici pour le définir")
        : Text(_home!, style: const TextStyle(fontSize: 12.0));
  }

  void _showIOSNotificationAlert() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Attention'),
          content: const Text(
              'Pour continuer à recevoir les notifications, ouvrez l\'application au moins une fois par semaine'),
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
      drawer: const AppDrawer(ViewType.settings),
      appBar: AppBar(
        title: GestureDetector(
            child: const Text("Paramètres"),
            onLongPress: () => navigator.pushNamed(debugRoute)),
      ),
      body: ListView(
        children: <Widget>[
          const ListHeader("Notifications"),
          ListTile(
              title: Text(
                  "L'application peut afficher une notification indiquant le point le plus proche de votre domicile, si ce dernier est définit.",
                  style: Theme.of(context).textTheme.caption)),
          ListTile(
            leading: const CenteredTileWidget(Icon(Icons.home)),
            title: const Text('Mon domicile'),
            subtitle: _homeLabel,
            onTap: () async {
              AddressSuggestion? suggestion = await navigator
                  .pushNamed(homeSelectRoute) as AddressSuggestion?;
              setState(() => _home = suggestion?.address ?? _home);
            },
            trailing: _home != null
                ? IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      Home.service.removeHome();
                      setState(() {
                        _home = null;
                        _showNotification = false;
                      });
                    })
                : null,
          ),
          SwitchListTile(
            secondary: const CenteredTileWidget(Icon(Icons.notifications)),
            title: const Text("Notifier la veille (vers 20h)"),
            value: _showNotification,
            onChanged: _home != null
                ? (bool value) => _setShowNotification(value)
                : null,
          ),
          const Divider(thickness: 2, height: 40),
          const ListHeader("Liens"),
          ListTile(
            leading: const CenteredTileWidget(Icon(Icons.help)),
            title: const Text("Assistance"),
            onTap: () => launchURL(assistanceUrl),
          ),
          ListTile(
            leading: const CenteredTileWidget(Icon(Icons.security)),
            title: const Text("Charte de la vie privée"),
            onTap: () => launchURL(privacyUrl),
          ),
          const About()
        ],
      ),
    );
  }
}
