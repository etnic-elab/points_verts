import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;
import 'package:points_verts/mapbox.dart';
import 'package:points_verts/platform_widget.dart';

import 'trip.dart';
import 'walk.dart';
import 'walk_results_list_view.dart';
import 'walk_results_map_view.dart';

enum PopupMenuActions { recalculatePosition }

class WalkList extends StatefulWidget {
  @override
  _WalkListState createState() => _WalkListState();
}

class _WalkListState extends State<WalkList> {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  final Widget _loadingWidget = Center(
    child: new CircularProgressIndicator(),
  );

  List<DateTime> _dates = new List<DateTime>();
  List<DropdownMenuItem<DateTime>> dropdownMenuItems =
      new List<DropdownMenuItem<DateTime>>();
  Map<DateTime, Future<List<Walk>>> _allWalks =
      HashMap<DateTime, Future<List<Walk>>>();
  Future<List<Walk>> _currentWalks;
  Walk _selectedWalk;
  DateTime _selectedDate;
  Position _currentPosition;
  bool _calculatingPosition = false;
  bool _error = false;

  @override
  void initState() {
    initializeDateFormatting("fr_BE");
    _retrieveDates();
    _getCurrentLocation();
    super.initState();
  }

  Future<List<Walk>> _retrieveWalks() async {
    if (_selectedDate == null) {
      return _currentWalks;
    }
    Future<List<Walk>> newList;
    if (_allWalks.containsKey(_selectedDate)) {
      print("Retrieving walks from cache");
      newList = _allWalks[_selectedDate];
    } else {
      try {
        print("Retrieving walks from endpoint");
        newList = _retrieveWalksFromEndpoint();
        _allWalks.putIfAbsent(_selectedDate, () => newList);
        if (_currentPosition != null) {
          newList = _calculateDistances(await newList);
        }
      } catch (err) {
        setState(() {
          _error = true;
        });
        return newList;
      }
    }

    setState(() {
      _currentWalks = newList;
    });
    return _currentWalks;
  }

  Future<List<Walk>> _retrieveWalksFromEndpoint() async {
    DateFormat dateFormat = new DateFormat("dd-MM-yyyy");
    List<Walk> newList = List<Walk>();
    var response = await http.get(
        "https://www.am-sport.cfwb.be/adeps/pv_data.asp?type=map&dt=${dateFormat.format(_selectedDate)}&activites=M,O");
    var fixed = _fixCsv(response.body);
    List<List<dynamic>> rowsAsListOfValues =
        const CsvToListConverter(fieldDelimiter: ';').convert(fixed);
    for (List<dynamic> walk in rowsAsListOfValues) {
      newList.add(Walk(
          city: walk[1],
          type: walk[2],
          lat: walk[3] != "" ? walk[3] : null,
          long: walk[4] != "" ? walk[4] : null,
          province: walk[5],
          date: walk[6],
          status: walk[9]));
    }
    return newList;
  }

  Future<List<Walk>> _calculateDistances(List<Walk> walks) async {
    for (Walk walk in walks) {
      if (walk.lat != null && walk.long != null) {
        double distance = await geolocator.distanceBetween(
            _currentPosition.latitude,
            _currentPosition.longitude,
            walk.lat,
            walk.long);
        walk.distance = distance;
      }
    }
    walks.sort((a, b) {
      if (a.distance != null && b.distance != null) {
        return a.distance.compareTo(b.distance);
      } else if (a.distance != null) {
        return -1;
      } else {
        return 1;
      }
    });
    for (int i = 0; i < walks.length; i++) {
      if (i < 5) {
        try {
          Walk walk = walks[i];
          retrieveTrip(_currentPosition.longitude, _currentPosition.latitude,
                  walk.long, walk.lat)
              .then((Trip trip) {
            walk.trip = trip;
            setState(() {});
          });
        } catch (err) {
          print('Cannot retrieve trip: $err');
        }
      } else {
        break;
      }
    }
    return walks;
  }

  void _retrieveDates() async {
    _retrieveDatesFromWorker().then((List<DateTime> items) {
      setState(() {
        _dates = items;
        dropdownMenuItems = generateDropdownItems(items);
        _selectedDate = items.isNotEmpty ? items.first : _getNextSunday();
      });
      _retrieveWalks();
    }).catchError((err) {
      print("Cannot retrieve dates: $err");
      setState(() {
        _dates = _generateDates();
        dropdownMenuItems = generateDropdownItems(_generateDates());
        _selectedDate = _getNextSunday();
      });
      _retrieveWalks();
    });
  }

  static List<DropdownMenuItem<DateTime>> generateDropdownItems(
      List<DateTime> dates) {
    DateFormat fullDate = DateFormat.yMMMMEEEEd("fr_BE");
    return dates.map((DateTime date) {
      return DropdownMenuItem<DateTime>(
          value: date, child: new Text(fullDate.format(date)));
    }).toList();
  }

  Future<List<DateTime>> _retrieveDatesFromWorker() async {
    try {
      String url = "https://points-verts.tbo.workers.dev/";
      var response = await http.get(url);
      List<dynamic> dates = jsonDecode(response.body);
      DateFormat dateFormat = new DateFormat("dd-MM-yyyy");
      return dates.map((dynamic date) => dateFormat.parse(date)).toList();
    } catch (err) {
      print("Cannot retrieve dates from worker: $err");
      return _retrieveDatesFromEndpoint();
    }
  }

  Future<List<DateTime>> _retrieveDatesFromEndpoint() async {
    String url = "https://www.am-sport.cfwb.be/adeps/pv_data.asp?type=dates";
    var response = await http.get(url);
    var document = parse(response.body);
    List<String> results = new List<String>();
    for (dom.Element element in document.getElementsByTagName('option')) {
      String value = element.attributes['value'];
      if (value != '0') {
        results.add(value);
      }
    }
    DateFormat dateFormat = new DateFormat("dd-MM-yyyy");
    return results.map((String date) => dateFormat.parse(date)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      androidBuilder: _androidLayout,
      iosBuilder: _iOSLayout,
    );
  }

  Widget _iOSLayout(BuildContext buildContext) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.list), title: Text('Listes')),
          BottomNavigationBarItem(icon: Icon(Icons.map), title: Text('Carte'))
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        var navBar = CupertinoNavigationBar(
            middle: Text('Points Verts Adeps',
                style: Theme.of(context).primaryTextTheme.title),
            backgroundColor: Theme.of(context).primaryColor);
        if (index == 0) {
          return CupertinoPageScaffold(
              navigationBar: navBar,
              child: SafeArea(
                  child: Scaffold(
                      body: _buildTab(
                          buildContext,
                          WalkResultsListView(
                              _currentWalks, _currentPosition)))));
        } else {
          return CupertinoPageScaffold(
              navigationBar: navBar,
              child: SafeArea(
                  child: Scaffold(
                      body: _buildTab(
                          buildContext,
                          WalkResultsMapView(
                              _currentWalks, _currentPosition, _selectedWalk,
                              (walk) {
                            setState(() {
                              _selectedWalk = walk;
                            });
                          })))));
        }
      },
    );
  }

  Widget _androidLayout(BuildContext buildContext) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Points Verts Adeps'),
            actions: <Widget>[
              PopupMenuButton<PopupMenuActions>(
                onSelected: (PopupMenuActions result) {
                  if (result == PopupMenuActions.recalculatePosition) {
                    _getCurrentLocation();
                  }
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<PopupMenuActions>>[
                  PopupMenuItem<PopupMenuActions>(
                    value: PopupMenuActions.recalculatePosition,
                    enabled: _calculatingPosition == false,
                    child: Text('Recalculer ma position'),
                  )
                ],
              )
            ],
            bottom: TabBar(
              tabs: <Widget>[Tab(text: "LISTE"), Tab(text: "CARTE")],
            ),
          ),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              _buildTab(
                  buildContext,
                  WalkResultsListView(
                    _currentWalks,
                    _currentPosition,
                  )),
              _buildTab(
                  buildContext,
                  WalkResultsMapView(
                      _currentWalks, _currentPosition, _selectedWalk, (walk) {
                    setState(() {
                      _selectedWalk = walk;
                    });
                  })),
            ],
          ),
        ));
  }

  Widget _buildTab(BuildContext context, Widget tabContent) {
    if (_dates == null) {
      return SizedBox.shrink();
    }
    return Column(
      children: <Widget>[
        _defineSearchPart(context),
        Expanded(child: _error ? _errorWidget() : tabContent),
      ],
    );
  }

  Widget _errorWidget() {
    return Card(
        child: Column(
      children: <Widget>[
        Spacer(),
        Icon(Icons.warning),
        Container(
            padding: EdgeInsets.all(5.0),
            child: Row(children: [
              Expanded(
                  child: Center(
                      child: Text(
                          "Une erreur est survenue lors de la récupération des données. Merci de réessayer plus tard.",
                          textAlign: TextAlign.center)))
            ])),
        RaisedButton(
            child: Text("Réessayer"),
            onPressed: () => _refreshWalks(clearDate: true)),
        Spacer()
      ],
    ));
  }

  Widget _dropdown(BuildContext context) {
    DateFormat fullDate = DateFormat.yMMMMEEEEd("fr_BE");
    return DropdownButton(
      value: _selectedDate,
      items: _dates.map((DateTime date) {
        return DropdownMenuItem<DateTime>(
            value: date, child: new Text(fullDate.format(date)));
      }).toList(),
      onChanged: (DateTime newValue) {
        setState(() {
          _selectedDate = newValue;
        });
        _refreshWalks();
      },
    );
  }

  _defineSearchPart(BuildContext context) {
    if (_dates.isNotEmpty) {
      return Container(
          margin: const EdgeInsets.only(left: 10, right: 10),
          child: Row(children: <Widget>[
            _dropdown(context),
            SizedBox.shrink(),
            Expanded(child: _resultNumber(context))
          ]));
    } else {
      return _loadingWidget;
    }
  }

  _resultNumber(BuildContext context) {
    return FutureBuilder(
      future: _currentWalks,
      builder: (BuildContext context, AsyncSnapshot<List<Walk>> snapshot) {
        if (snapshot.hasData && window.physicalSize.width >= 1080) {
          return Align(
              alignment: Alignment.centerRight,
              child: Text("${snapshot.data.length.toString()} résultat(s)"));
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Future<List<Walk>> _refreshWalks({bool clearDate = false}) {
    if (clearDate) {
      _allWalks.remove(_selectedDate);
    }
    setState(() {
      _error = false;
      _currentWalks = null;
      _selectedWalk = null;
    });
    return _retrieveWalks();
  }

  String _fixCsv(String csv) {
    List<String> result = new List<String>();
    List<String> splitted = csv.split(';');
    String current = "";
    int tokens = 0;
    for (String token in splitted) {
      if (tokens == 0) {
        current = token;
      } else {
        current = current + ";" + token;
      }
      tokens++;
      if (tokens == 10) {
        result.add(current);
        tokens = 0;
      }
    }
    return result.join('\r\n');
  }

  _getCurrentLocation() {
    setState(() {
      _calculatingPosition = true;
    });
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        _calculatingPosition = false;
      });
      _retrieveWalks();
    }).catchError((e) {
      print("Cannot retrieve current position: $e");
    });
  }

  static DateTime _getNextSunday() {
    DateTime current = new DateTime.now();
    Duration oneDay = new Duration(days: 1);
    while (current.weekday != DateTime.sunday) {
      current = current.add(oneDay);
    }
    return current;
  }

  static List<DateTime> _generateDates() {
    List<DateTime> results = new List<DateTime>();
    DateTime current = new DateTime.now();
    Duration oneDay = new Duration(days: 1);
    Duration aWeek = new Duration(days: 7);
    while (current.weekday != DateTime.sunday) {
      current = current.add(oneDay);
    }
    while (results.length < 10) {
      results.add(current);
      current = current.add(aWeek);
    }
    return results;
  }
}
