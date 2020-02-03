import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'platform_widget.dart';
import 'walk.dart';
import 'walk_utils.dart';

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
        body: _webView(walk));
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
