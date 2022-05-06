import 'package:flutter/material.dart';
import 'package:points_verts/init_screen.dart';
import 'package:points_verts/models/walk.dart';
import 'package:points_verts/views/settings/home_select.dart';
import 'package:points_verts/views/settings/settings.dart';
import 'package:points_verts/views/walks/details/view.dart';
import 'package:points_verts/views/walks/directory_view.dart';
import 'package:points_verts/views/walks/calendar_view.dart';

const String initScreenRoute = '/';
const String calendarRoute = '/calendar';
const String directoryRoute = '/directory';
const String walkDetailRoute = '/walk_detail';
const String homeSelectRoute = '/home_select';
const String settingsRoute = '/settings';
const String debugRoute = '/debug';

class NavigationRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initScreenRoute:
        return MaterialPageRoute(builder: (_) => const InitScreen());
      case calendarRoute:
        return MaterialPageRoute(builder: (_) => const CalendarView());
      case directoryRoute:
        return MaterialPageRoute(builder: (_) => const WalkDirectoryView());
      case walkDetailRoute:
        Walk walk = settings.arguments as Walk;
        return MaterialPageRoute(builder: (_) => WalkDetailsView(walk));
      case homeSelectRoute:
        return MaterialPageRoute(builder: (_) => const HomeSelect());
      case settingsRoute:
        return MaterialPageRoute(builder: (_) => const Settings());
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get navigate => navigatorKey.currentState!;
}
