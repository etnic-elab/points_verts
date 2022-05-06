import 'package:points_verts/models/address_suggestion.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:points_verts/services/service_locator.dart';

class Home {
  Home._();

  static final Home service = Home._();

  Future<void> addHome(AddressSuggestion suggestion) async {
    await Future.wait([
      prefs.setString(
          Prefs.homeCoords, "${suggestion.latitude},${suggestion.longitude}"),
      prefs.setString(Prefs.homeLabel, suggestion.address),
    ]);
    notification.scheduleNextNearestWalkNotifications();
  }

  Future<void> removeHome() async {
    await Future.wait([
      prefs.remove(Prefs.homeCoords),
      prefs.remove(Prefs.homeLabel),
      prefs.remove(Prefs.showNotification)
    ]);
    notification.cancelNextNearestWalkNotifications();
  }
}
