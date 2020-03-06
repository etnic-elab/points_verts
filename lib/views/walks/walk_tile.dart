import 'dart:io';
import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'geo_button.dart';
import '../../models/walk.dart';
import 'walk_details_view.dart';
import 'walk_utils.dart';
import '../../models/weather.dart';
import '../../services/openweather.dart';

class WalkTile extends StatelessWidget {

  final ContainerTransitionType _transitionType = ContainerTransitionType.fade;

  WalkTile({this.walk});

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    bool smallScreen = window.physicalSize.width <= 640;
    return OpenContainer(
      transitionType: _transitionType,
      openBuilder: (BuildContext _, VoidCallback openContainer) {
        return WalkDetailsView(walk);
      },
      tappable: false,
      closedShape: const RoundedRectangleBorder(),
      closedElevation: 0.0,
      closedBuilder: (BuildContext _, VoidCallback openContainer) {
        return ListTile(
          dense: smallScreen,
          leading: _weatherIcon(),
          title: Text(walk.city),
          subtitle: Text(
              "${walk.type == 'M' ? 'Marche' : 'Orientation'} - ${walk.province}"),
          enabled: !walk.isCancelled(),
          onTap: openContainer,
          trailing: walk.isCancelled() ? Text("Annulé") : GeoButton(walk: walk),
        );
      },
    );
  }

  Widget _weatherIcon() {
    if (walk.isCancelled()) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[displayIcon(walk)]);
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
          return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[displayIcon(walk)]);
        });
  }
}