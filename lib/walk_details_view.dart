import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:points_verts/openweather.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'platform_widget.dart';
import 'walk.dart';
import 'walk_utils.dart';
import 'weather.dart';

class WalkDetailsView extends StatelessWidget {
  WalkDetailsView(this.walk);

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      androidBuilder: _androidLayout,
      iosBuilder: _iOSLayout,
    );
  }

  Widget _iOSLayout(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            backgroundColor: Theme.of(context).primaryColor,
            middle: Text(walk.city,
                style: Theme.of(context).primaryTextTheme.title)),
        child: SafeArea(child: _webView(walk)));
  }

  Widget _androidLayout(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.directions_car),
                onPressed: () {
                  launchGeoApp(walk);
                })
          ],
          title: Text(walk.city),
        ),
        body: Column(children: <Widget>[
          walk.weathers != null ? _sectionTitle(context, "Météo du ${walk.date}") : SizedBox(),
          walk.weathers != null ? _weather() : SizedBox(),
          walk.weathers != null ? Divider() : SizedBox(),
          Expanded(child: _webView(walk))
        ]));
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Text(
            title,
            style: TextStyle(
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.bold),
          ),
        ));
  }

  Widget _weather() {
    return FutureBuilder(
        future: walk.weathers,
        builder: (BuildContext context, AsyncSnapshot<List<Weather>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              List<Weather> weathers = snapshot.data;
              List<Widget> widgets = List<Widget>();
              for (Weather weather in weathers) {
                widgets.add(Card(
                    margin: EdgeInsets.all(0),
                    child: Padding(
                        padding: EdgeInsets.only(
                            left: 10, right: 10, top: 5, bottom: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("${weather.timestamp.hour}h"),
                            getWeatherIcon(weather, context),
                            Text("${weather.temperature.round()}°"),
                            Text("${weather.windSpeed.round()} km/h")
                          ],
                        ))));
              }
              return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: widgets);
            }
          }
          return SizedBox();
        });
  }

  Widget _webView(Walk walk) {
    return WebView(
        initialUrl:
            "https://www.am-sport.cfwb.be/adeps/pv_detail.asp?i=${walk.id}",
        navigationDelegate: (NavigationRequest request) {
          if (request.url.startsWith("https://www.google.be/maps/")) {
            launchGeoApp(walk);
            return NavigationDecision.prevent;
          } else {
            return NavigationDecision.navigate;
          }
        });
  }
}
