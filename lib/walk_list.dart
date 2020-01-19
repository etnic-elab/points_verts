import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:geolocator/geolocator.dart';
import 'package:points_verts/app_drawer.dart';
import 'package:points_verts/settings.dart';

import 'api.dart';
import 'database.dart';
import 'dates_dropdown.dart';
import 'mapbox.dart';
import 'platform_widget.dart';
import 'trip.dart';
import 'walk.dart';
import 'walk_date.dart';
import 'walk_results_list_view.dart';
import 'walk_results_map_view.dart';

enum PopupMenuActions { recalculatePosition, settings }

class WalkList extends StatefulWidget {
  @override
  _WalkListState createState() => _WalkListState();
}

class _WalkListState extends State<WalkList> {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  Future<List<WalkDate>> _dates;
  Map<DateTime, List<Walk>> _allWalks = HashMap<DateTime, List<Walk>>();
  Future<List<Walk>> _currentWalks;
  Walk _selectedWalk;
  WalkDate _selectedDate;
  Position _currentPosition;
  bool _calculatingPosition = false;

  @override
  void initState() {
    initializeDateFormatting("fr_BE");
    _retrieveDates();
    _getCurrentLocation();
    super.initState();
  }

  _retrieveWalks() {
    setState(() {
      _currentWalks = null;
    });
    _retrieveWalksHelper();
  }

  _retrieveWalksHelper() async {
    Future<List<Walk>> newList;
    if (_allWalks.containsKey(_selectedDate?.date)) {
      newList = Future.value(_allWalks[_selectedDate.date]);
    } else {
      newList = retrieveWalksFromEndpoint(_selectedDate?.date);
    }
    setState(() {
      _currentWalks = newList;
    });
    if (_currentPosition != null) {
      newList = _calculateDistances(await newList);
      setState(() {
        _currentWalks = newList;
      });
    }
    List<Walk> results = await newList;
    _allWalks.putIfAbsent(_selectedDate.date, () => results);
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
    _dates = _getWalkDates();
    _dates.then((List<WalkDate> items) {
      setState(() {
        _selectedDate = items.first;
      });
      _retrieveWalks();
    }).catchError((err) {
      print("Cannot retrieve dates: $err");
      setState(() {
        _currentWalks = Future.error(err);
      });
    });
  }

  Future<List<WalkDate>> _getWalkDates() async {
    List<WalkDate> walkDates = await DBProvider.db.getWalkDates();
    if (walkDates.length == 0) {
      List<DateTime> dates = await retrieveDatesFromWorker();
      walkDates = dates.map((DateTime date) {
        return WalkDate(date: date);
      }).toList();
      DBProvider.db.insertWalkDates(walkDates);
    }
    return walkDates;
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
              child:
                  SafeArea(child: Scaffold(body: _buildListTab(buildContext))));
        } else {
          return CupertinoPageScaffold(
              navigationBar: navBar,
              child:
                  SafeArea(child: Scaffold(body: _buildMapTab(buildContext))));
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
                  } else if (result == PopupMenuActions.settings) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Settings()));
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
          drawer: AppDrawer(),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              _buildListTab(buildContext),
              _buildMapTab(buildContext),
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
        Expanded(child: tabContent),
      ],
    );
  }

  Widget _buildListTab(BuildContext buildContext) {
    return _buildTab(buildContext,
        WalkResultsListView(_currentWalks, _currentPosition, _refreshWalks));
  }

  Widget _buildMapTab(BuildContext buildContext) {
    return _buildTab(
        buildContext,
        WalkResultsMapView(_currentWalks, _currentPosition, _selectedWalk,
            (walk) {
          setState(() {
            _selectedWalk = walk;
          });
        }, _refreshWalks));
  }

  Widget _defineSearchPart(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        child: Row(children: <Widget>[
          DatesDropdown(
              dates: _dates,
              selectedDate: _selectedDate,
              onChanged: (WalkDate date) {
                setState(() {
                  _selectedDate = date;
                  _retrieveWalks();
                });
              }),
          SizedBox.shrink(),
          Expanded(child: _resultNumber(context))
        ]));
  }

  Widget _resultNumber(BuildContext context) {
    return FutureBuilder(
      future: _currentWalks,
      builder: (BuildContext context, AsyncSnapshot<List<Walk>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return Align(
                alignment: Alignment.centerRight,
                child: Text("${snapshot.data.length.toString()} résultat(s)"));
          }
        }
        return SizedBox.shrink();
      },
    );
  }

  void _refreshWalks({bool clearDate = false}) {
    if (clearDate) {
      _allWalks.remove(_selectedDate);
    }
    _retrieveDates();
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
      if (_selectedDate != null) {
        _retrieveWalks();
      }
    }).catchError((e) {
      print("Cannot retrieve current position: $e");
      _retrieveWalks();
    });
  }
}
