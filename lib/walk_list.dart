import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:geolocator/geolocator.dart';
import 'package:points_verts/app_drawer.dart';
import 'package:points_verts/place_select.dart';
import 'package:points_verts/prefs.dart';
import 'package:points_verts/settings.dart';

import 'api.dart';
import 'database.dart';
import 'dates_dropdown.dart';
import 'mapbox.dart';
import 'platform_widget.dart';
import 'walk.dart';
import 'walk_date.dart';
import 'walk_results_list_view.dart';
import 'walk_results_map_view.dart';

enum PopupMenuActions { recalculatePosition, settings }
enum Places { home, current }

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
  Position _homePosition;
  Places _selectedPlace;
  bool _calculatingPosition = false;

  @override
  void initState() {
    initializeDateFormatting("fr_BE");
    _retrieveDates();
    _getCurrentLocation();
    super.initState();
  }

  _retrieveHomePosition() async {
    String homePos = await PrefsProvider.prefs.getString("home_coords");
    if (homePos != null) {
      List<String> split = homePos.split(",");
      setState(() {
        _homePosition = Position(
            latitude: double.parse(split[0]),
            longitude: double.parse(split[1]));
        _selectedPlace = Places.home;
      });
    }
  }

  Position get selectedPosition {
    if (_selectedPlace == Places.current) {
      return _currentPosition;
    } else if (_selectedPlace == Places.home) {
      return _homePosition;
    } else {
      return null;
    }
  }

  _retrieveWalks() {
    setState(() {
      _currentWalks = null;
      _selectedWalk = null;
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
    if (selectedPosition != null) {
      newList = _calculateDistances(await newList);
    }
    List<Walk> results = await newList;
    setState(() {
      _currentWalks = newList;
    });
    if (results.isNotEmpty && _selectedDate != null) {
      _allWalks.putIfAbsent(_selectedDate.date, () => results);
    }
  }

  Future<List<Walk>> _calculateDistances(List<Walk> walks) async {
    for (Walk walk in walks) {
      if (walk.lat != null && walk.long != null) {
        if (walk.isCancelled()) {
          walk.distance = double.maxFinite;
        } else {
          double distance = await geolocator.distanceBetween(
              selectedPosition.latitude,
              selectedPosition.longitude,
              walk.lat,
              walk.long);
          walk.distance = distance;
        }
      }
    }
    walks.sort((a, b) => sortWalks(a, b));
    try {
      await retrieveTrips(
          selectedPosition.longitude, selectedPosition.latitude, walks);
    } catch (err) {
      print("Cannot retrieve trips: $err");
    }
    walks.sort((a, b) => sortWalks(a, b));
    return walks;
  }

  int sortWalks(Walk a, Walk b) {
    if (a.trip != null && b.trip != null) {
      return a.trip.duration.compareTo(b.trip.duration);
    } else if (a.distance != null && b.distance != null) {
      return a.distance.compareTo(b.distance);
    } else if (a.distance != null) {
      return -1;
    } else {
      return 1;
    }
  }

  void _retrieveDates() async {
    _dates = _getWalkDates();
    await _retrieveHomePosition();
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
    return _buildTab(
        buildContext,
        WalkResultsListView(
            _currentWalks, selectedPosition, _selectedPlace, _refreshWalks));
  }

  Widget _buildMapTab(BuildContext buildContext) {
    return _buildTab(
        buildContext,
        WalkResultsMapView(
            _currentWalks, selectedPosition, _selectedPlace, _selectedWalk,
            (walk) {
          setState(() {
            _selectedWalk = walk;
          });
        }, _refreshWalks));
  }

  Widget _defineSearchPart(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              DatesDropdown(
                  dates: _dates,
                  selectedDate: _selectedDate,
                  onChanged: (WalkDate date) {
                    setState(() {
                      _selectedDate = date;
                      _retrieveWalks();
                    });
                  }),
              _homePosition != null && _currentPosition != null
                  ? PlaceSelect(
                      currentPlace: _selectedPlace,
                      onChanged: (Places place) {
                        setState(() {
                          _selectedPlace = place;
                        });
                        _retrieveWalksHelper();
                      })
                  : Expanded(child: _resultNumber(context))
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
    if (_selectedPlace == Places.home) {
      return;
    }
    setState(() {
      _calculatingPosition = true;
    });
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.medium)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        _selectedPlace = Places.current;
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
