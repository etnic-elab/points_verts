import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:points_verts/mapbox.dart';
import 'package:points_verts/mapbox_suggestion.dart';

import 'loading.dart';
import 'platform_widget.dart';

class SettingsHomeSelect extends StatefulWidget {
  SettingsHomeSelect(this.setHomeCallback, this.removeHomeCallback);

  final Function(MapBoxSuggestion) setHomeCallback;
  final Function removeHomeCallback;

  @override
  _SettingsHomeSelectState createState() =>
      _SettingsHomeSelectState(setHomeCallback, removeHomeCallback);
}

class _SettingsHomeSelectState extends State<SettingsHomeSelect> {
  _SettingsHomeSelectState(this.setHomeCallback, this.removeHomeCallback);

  final Function(MapBoxSuggestion) setHomeCallback;
  final Function removeHomeCallback;
  final _homeSearchController = TextEditingController();
  Timer _debounce;
  Future<List<MapBoxSuggestion>> _suggestions =
      Future.value(List<MapBoxSuggestion>());

  @override
  void initState() {
    super.initState();
    _homeSearchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _homeSearchController.dispose();
    super.dispose();
  }

  _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _suggestions = retrieveSuggestions(_homeSearchController.text);
      });
    });
  }

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
            middle: Text("Recherche du domicile",
                style: Theme.of(context).primaryTextTheme.title)),
        child: SafeArea(child: _pageContent(context)));
  }

  Widget _androidLayout(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  removeHomeCallback();
                  _homeSearchController.removeListener(_onSearchChanged);
                  Navigator.of(context).pop();
                })
          ],
          title: Text("Recherche du domicile"),
        ),
        body: _pageContent(context));
  }

  Widget _pageContent(BuildContext context) {
    return Column(children: <Widget>[
      Padding(
          padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 20.0),
          child: TextField(
            controller: _homeSearchController,
            decoration:
                InputDecoration(hintText: "Rechercher l'adresse du domicile"),
          )),
      Expanded(child: _suggestionList())
    ]);
  }

  Widget _suggestionList() {
    return FutureBuilder(
        future: _suggestions,
        builder: (BuildContext context,
            AsyncSnapshot<List<MapBoxSuggestion>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              List<MapBoxSuggestion> suggestions = snapshot.data;
              return ListView.separated(
                  itemCount: suggestions.length,
                  separatorBuilder: (context, i) => Divider(height: 0.5),
                  itemBuilder: (context, i) {
                    MapBoxSuggestion suggestion = suggestions[i];
                    return ListTile(
                        title: Text(suggestion.address),
                        dense: true,
                        onTap: () {
                          setHomeCallback(suggestion);
                          _homeSearchController
                              .removeListener(_onSearchChanged);
                          Navigator.of(context).pop();
                        });
                  });
            } else if (snapshot.hasError) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.warning),
                  Container(
                      padding: EdgeInsets.all(5.0),
                      child: Row(children: [
                        Expanded(
                            child: Center(
                                child: Text(
                                    "Une erreur est survenue lors de la récupération des données. Merci de réessayer plus tard.",
                                    textAlign: TextAlign.center)))
                      ]))
                ],
              );
            } else {
              return Loading();
            }
          } else {
            return Loading();
          }
        });
  }
}
