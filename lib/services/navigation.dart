import 'package:flutter/material.dart';
import 'package:points_verts/init_screen.dart';
import 'package:points_verts/models/walk.dart';
import 'package:points_verts/views/directory/walk_directory_view.dart';
import 'package:points_verts/views/walks/walk_details_view.dart';
import 'package:points_verts/views/walks/walks_view.dart';

const String initScreenRoute = '/';
const String calendarRoute = '/calendar';
const String directoryRoute = '/directory';
const String walkDetailRoute = '/walk_detail';

class NavigationRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initScreenRoute:
        return MaterialPageRoute(builder: (_) => const InitScreen());
      case calendarRoute:
        return MaterialPageRoute(builder: (_) => const WalksView());
      case directoryRoute:
        return MaterialPageRoute(builder: (_) => const WalkDirectoryView());
      case walkDetailRoute:
        Walk walk = settings.arguments as Walk;
        return MaterialPageRoute(builder: (_) => WalkDetailsView(walk));
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
