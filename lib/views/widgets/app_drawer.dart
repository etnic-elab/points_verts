import 'package:flutter/material.dart';
import 'package:points_verts/abstractions/company_data.dart';
import 'package:points_verts/models/view_type.dart';
import 'package:points_verts/services/assets.dart';
import 'package:points_verts/services/navigation.dart';
import 'package:points_verts/services/service_locator.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer(this.currentView, {Key? key}) : super(key: key);

  final ViewType currentView;

  @override
  Widget build(BuildContext context) {
    Brightness brightness = Theme.of(context).brightness;
    return Drawer(
      elevation: 6.0,
      child: ListView(
        padding: const EdgeInsets.only(right: 8.0),
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: Assets.asset.image(brightness, Assets.splash),
                  fit: BoxFit.contain,
                ),
                color: brightness == Brightness.light
                    ? CompanyColors.lightBrown
                    : null),
            child: Container(),
          ),
          ...viewTiles,
        ],
      ),
    );
  }

  List<Widget> get viewTiles =>
      [ViewType.calendarList, ViewType.directory, ViewType.settings]
          .map((ViewType viewType) =>
              _ViewTile(viewType, viewType == currentView))
          .toList();
}

class _ViewTile extends StatelessWidget {
  const _ViewTile(this.viewType, this.isCurrentView, {Key? key})
      : super(key: key);

  final ViewType viewType;
  final bool isCurrentView;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(50))),
      tileColor:
          isCurrentView ? CompanyColors.greenPrimary.withOpacity(0.35) : null,
      leading: Icon(_icon),
      title: Text(_title),
      onTap: () => _navigateTo(context),
    );
  }

  void _navigateTo(BuildContext context) {
    if (isCurrentView) return Navigator.pop(context);
    navigator.pushReplacementNamed(_route);
  }

  String get _title {
    switch (viewType) {
      case ViewType.calendarList:
        return 'Calendrier';
      case ViewType.directory:
        return 'Annuaire';
      case ViewType.settings:
        return 'Paramètres';
      default:
        return 'No title for $viewType';
    }
  }

  IconData get _icon {
    switch (viewType) {
      case ViewType.calendarList:
        return Icons.calendar_month;
      case ViewType.directory:
        return Icons.local_library;
      case ViewType.settings:
        return Icons.settings;
      default:
        return Icons.error;
    }
  }

  String get _route {
    switch (viewType) {
      case ViewType.calendarList:
        return calendarRoute;
      case ViewType.directory:
        return directoryRoute;
      case ViewType.settings:
        return settingsRoute;
      default:
        return initScreenRoute;
    }
  }
}
