import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:points_verts/walk_details.dart';

import 'api.dart';
import 'loading.dart';
import 'mapbox.dart';
import 'platform_widget.dart';
import 'trip.dart';
import 'walk.dart';
import 'walk_date_utils.dart';
import 'walk_results_list_view.dart';
import 'walk_results_map_view.dart';

enum PopupMenuActions { recalculatePosition }

class WalkList extends StatefulWidget {
  @override
  _WalkListState createState() => _WalkListState();
}

class _WalkListState extends State<WalkList> {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  List<DateTime> _dates = new List<DateTime>();
  List<DropdownMenuItem<DateTime>> dropdownMenuItems =
      new List<DropdownMenuItem<DateTime>>();
  Map<DateTime, List<Walk>> _allWalks = HashMap<DateTime, List<Walk>>();
  Future<List<Walk>> _currentWalks;
  Walk _selectedWalk;
  DateTime _selectedDate;
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
    if (_selectedDate == null) {
      return;
    }

    setState(() {
      _currentWalks = null;
    });
    _retrieveWalksHelper();
  }

  _retrieveWalksHelper() async {
    Future<List<Walk>> newList;
    if (_allWalks.containsKey(_selectedDate)) {
      newList = Future.value(_allWalks[_selectedDate]);
    } else {
      newList = retrieveWalksFromEndpoint(_selectedDate);
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
    _allWalks.putIfAbsent(_selectedDate, () => results);
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
    retrieveDatesFromWorker().then((List<DateTime> items) {
      setState(() {
        _dates = items;
        dropdownMenuItems = generateDropdownItems(items);
        _selectedDate = items.isNotEmpty ? items.first : getNextSunday();
      });
      _retrieveWalks();
    }).catchError((err) {
      print("Cannot retrieve dates: $err");
      List<DateTime> dates = generateDates();
      setState(() {
        _dates = dates;
        dropdownMenuItems = generateDropdownItems(dates);
        _selectedDate = getNextSunday();
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
                          WalkResultsListView(_currentWalks, _currentPosition,
                              _refreshWalks)))));
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
                          }, _refreshWalks)))));
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
                      _currentWalks, _currentPosition, _refreshWalks)),
              _buildTab(
                  buildContext,
                  WalkResultsMapView(
                      _currentWalks, _currentPosition, _selectedWalk, (walk) {
                    setState(() {
                      _selectedWalk = walk;
                    });
                  }, _refreshWalks)),
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
      return Loading();
    }
  }

  _resultNumber(BuildContext context) {
    return FutureBuilder(
      future: _currentWalks,
      builder: (BuildContext context, AsyncSnapshot<List<Walk>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && window.physicalSize.width >= 1080) {
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
    _retrieveWalks();
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
      _retrieveWalks();
    });
  }
}
