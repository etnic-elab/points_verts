import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../tile_icon.dart';
import '../../models/walk.dart';
import 'walk_details_view.dart';
import 'walk_icon.dart';
import '../../models/weather.dart';
import '../../services/openweather.dart';

bool smallScreen = window.physicalSize.width <= 640;

class WalkTile extends StatelessWidget {
  WalkTile(this.walk);

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 3.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
          leading: _weatherIcon(),
          title: Text(walk.city, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("${walk.type} - ${walk.province}"),
          onTap: () => Navigator.push(context, _pageRoute()),
          trailing: Icon(Icons.keyboard_arrow_right),
        ));
  }

  Widget _weatherIcon() {
    if (walk.isCancelled()) {
      return TileIcon(WalkIcon(walk));
    }
    return FutureBuilder(
        future: walk.weathers,
        builder: (BuildContext context, AsyncSnapshot<List<Weather>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data.length > 0) {
              Weather weather = snapshot.data[0];
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  getWeatherIcon(weather, context),
                  Text("${weather.temperature.round()}°"),
                ],
              );
            }
          }
          return TileIcon(WalkIcon(walk));
        });
  }

  PageRoute _pageRoute() {
    return MaterialPageRoute(builder: (context) => WalkDetailsView(walk));
  }
}
