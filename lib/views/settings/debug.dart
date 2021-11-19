import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:points_verts/services/notification.dart';
import 'package:points_verts/services/prefs.dart';

class Debug extends StatelessWidget {
  const Debug({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Debug"),
        ),
        body: ListView(
          children: <Widget>[
            _LastWalkUpdateTile(),
            const Divider(height: 0.5),
            _GeoPosTile(),
            const Divider(height: 0.5),
            _PendingNotificationsTile(),
            const Divider(height: 0.5),
            _LastBackgroundFetch()
          ],
        ));
  }
}

class _LastWalkUpdateTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: PrefsProvider.prefs.getString("last_walk_update"),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return ListTile(
            title: const Text("Dernière mise à jour de la liste des marches"),
            subtitle: Text("${formatDate(snapshot.data!)} (heure locale)"),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _GeoPosTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: PrefsProvider.prefs.getString("home_coords"),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (snapshot.hasData) {
          return ListTile(
            title: const Text("Coordonnées GPS de l'emplacement de référence"),
            subtitle: Text(snapshot.data!),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _PendingNotificationsTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: NotificationManager.instance.pendingNotifications(),
        builder: (BuildContext context,
            AsyncSnapshot<List<PendingNotificationRequest>> snapshot) {
          if (snapshot.hasData) {
            List<PendingNotificationRequest> requests = snapshot.data!;
            if (requests.isNotEmpty) {
              return ListTile(
                isThreeLine: true,
                title: const Text("Prochaines notifications planifiées"),
                subtitle: Text(
                  generatePendingNotificationsSubtitle(requests),
                  style: const TextStyle(fontSize: 12.0),
                ),
              );
            }
          }
          return const SizedBox.shrink();
        });
  }
}

String generatePendingNotificationsSubtitle(
    List<PendingNotificationRequest> requests) {
  String result = "";
  for (int i = 0; i < requests.length; i++) {
    PendingNotificationRequest request = requests[i];
    result = result + request.title! + '\n' + request.body!;
    if (i != requests.length - 1) {
      result = result + "\n\n";
    }
  }
  return result;
}

class _LastBackgroundFetch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: PrefsProvider.prefs.getString("last_background_fetch"),
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return ListTile(
              title: const Text("Dernière actualisation en arrière-plan"),
              subtitle: Text("${formatDate(snapshot.data!)} (heure locale)"),
            );
          }
          return const SizedBox.shrink();
        });
  }
}

String formatDate(String date) {
  DateFormat dateFormat = DateFormat.MMMMEEEEd("fr").add_Hms();
  DateTime dateTime = DateTime.parse(date).toLocal();
  return dateFormat.format(dateTime);
}
