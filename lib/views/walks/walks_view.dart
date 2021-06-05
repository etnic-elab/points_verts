import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:geolocator/geolocator.dart';
import 'package:points_verts/models/walk_filter.dart';
import 'package:points_verts/models/weather.dart';
import 'package:points_verts/services/database.dart';
import 'package:points_verts/views/loading.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:points_verts/views/walks/filter_page.dart';

import 'dates_dropdown.dart';
import '../../services/openweather.dart';
import '../../models/walk.dart';
import '../../models/coordinates.dart';
import 'walk_results_list_view.dart';
import 'walk_results_map_view.dart';
import 'walk_utils.dart';

enum Places { home, current }
enum ViewType { list, map }

const String TAG = "dev.alpagaga.points_verts.WalkList";

class WalksView extends StatefulWidget {
  @override
  _WalksViewState createState() => _WalksViewState();
}

class _WalksViewState extends State<WalksView> with WidgetsBindingObserver {
  Future<List<DateTime>>? _dates;
  Future<List<Walk>>? _currentWalks;
  Walk? _selectedWalk;
  DateTime? _selectedDate;
  Coordinates? _currentPosition;
  Coordinates? _homePosition;
  ViewType _viewType = ViewType.list;
  WalkFilter? _filter;

  @override
  void initState() {
    initializeDateFormatting("fr_BE");
    _retrieveData();
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _retrieveData();
    }
  }

  void _firstLaunch() async {
    bool firstLaunch = await PrefsProvider.prefs
        .getBoolean(key: 'first_launch', defaultValue: true);
    if (firstLaunch) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      final snackBar = SnackBar(
          duration: Duration(days: 1),
          action: SnackBarAction(
            onPressed: () {
              PrefsProvider.prefs.setBoolean("first_launch", false);
            },
            label: "OK",
          ),
          content: const Text(
              "Pour voir en un coup d'œil les marches les plus proches de chez vous, n'hésitez pas à indiquer votre adresse dans les Paramètres !",
              textAlign: TextAlign.justify));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> _retrieveData() async {
    String? filterString =
        await PrefsProvider.prefs.getString("calendar_walk_filter");
    WalkFilter filter;
    if (filterString != null) {
      filter = WalkFilter.fromJson(jsonDecode(filterString));
    } else {
      filter = WalkFilter();
    }
    setState(() {
      _currentWalks = null;
      _selectedWalk = null;
      _currentPosition = null;
      _homePosition = null;
      _filter = filter;
    });
    _retrieveDates();
  }

  _retrievePosition() async {
    Coordinates? home = await retrieveHomePosition();
    if (home != null) {
      setState(() {
        _homePosition = home;
        _filter!.selectedPlace = Places.home;
      });
    } else {
      setState(() {
        _filter!.selectedPlace = Places.current;
      });
    }
    if (await PrefsProvider.prefs.getBoolean(key: "use_location") == true) {
      _getCurrentLocation();
    }
  }

  Coordinates? get selectedPosition {
    if (_filter!.selectedPlace == Places.current) {
      return _currentPosition;
    } else if (_filter!.selectedPlace == Places.home) {
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
    Future<List<Walk>> newList = retrieveSortedWalks(_selectedDate,
        filter: _filter, position: selectedPosition);
    if (_selectedDate != null &&
        _selectedDate!.difference(DateTime.now()).inDays < 5) {
      try {
        _retrieveWeathers(await newList).then((_) {
          setState(() {});
        });
      } catch (err) {
        print("Cannot retrieve weather info: $err");
      }
    }
    setState(() {
      _currentWalks = newList;
    });
    _firstLaunch();
    newList.then((_) {
      setState(() {});
    });
  }

  Future _retrieveWeathers(List<Walk> walks) async {
    List<Future<List<Weather>>> weathers = [];
    for (int i = 0; i < math.min(walks.length, 5); i++) {
      Walk walk = walks[i];
      if (_selectedDate != null &&
          walk.weathers.isEmpty &&
          walk.long != null &&
          walk.lat != null &&
          !walk.isCancelled()) {
        Future<List<Weather>> future =
            getWeather(walk.long!, walk.lat!, _selectedDate!);
        future.then((weathers) {
          walk.weathers = weathers;
        });
        weathers.add(future);
      }
    }
    return Future.wait(weathers);
  }

  void _retrieveDates() async {
    _dates = DBProvider.db.getWalkDates();
    await _retrievePosition();
    _dates!.then((List<DateTime> items) async {
      String? lastSelectedDateString =
          await PrefsProvider.prefs.getString("last_selected_date");
      if (lastSelectedDateString != null) {
        setState(() {
          _selectedDate = DateTime.parse(lastSelectedDateString);
        });
      }
      if (items.isNotEmpty && !items.contains(_selectedDate)) {
        setState(() {
          _selectedDate = items.first;
        });
        PrefsProvider.prefs
            .setString("last_selected_date", items.first.toIso8601String());
      }
      _retrieveWalks();
    }).catchError((err) {
      print("Cannot retrieve dates: $err");
      setState(() {
        _currentWalks = Future.error(err);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendrier'),
        actions: <Widget>[
          IconButton(
            icon: Icon(_viewType == ViewType.list ? Icons.map : Icons.list),
            onPressed: () {
              setState(() {
                _viewType =
                    _viewType == ViewType.list ? ViewType.map : ViewType.list;
              });
            },
          )
        ],
      ),
      body: _buildTab(),
    );
  }

  Widget _buildTab() {
    Future<List<DateTime>>? dates = _dates;
    if (dates == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Loading(),
          Container(
              padding: EdgeInsets.all(10),
              child: Text("Récupération des données..."))
        ],
      );
    }
    return Column(
      children: <Widget>[
        _defineSearchPart(dates),
        Divider(height: 0.0),
        Expanded(
            child: _viewType == ViewType.list
                ? WalkResultsListView(_currentWalks, selectedPosition,
                    _filter!.selectedPlace, _retrieveData)
                : WalkResultsMapView(_currentWalks, selectedPosition,
                    _filter!.selectedPlace, _selectedWalk, (walk) {
                    setState(() {
                      _selectedWalk = walk;
                    });
                  }, _retrieveData)),
      ],
    );
  }

  void onDateChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
      _retrieveWalks();
    });
    PrefsProvider.prefs.setString("last_selected_date", date.toIso8601String());
  }

  void onFilterPressed() async {
    WalkFilter? newFilter = await Navigator.of(context).push<WalkFilter>(
        MaterialPageRoute(
            builder: (context) => FilterPage(
                _filter!, _homePosition != null && _currentPosition != null)));
    if (newFilter != null) {
      setState(() {
        _filter = newFilter;
      });
      await PrefsProvider.prefs
          .setString("calendar_walk_filter", jsonEncode(newFilter));
      _retrieveWalks();
    }
  }

  Widget _defineSearchPart(Future<List<DateTime>> dates) {
    return FutureBuilder(
        future: dates,
        builder:
            (BuildContext context, AsyncSnapshot<List<DateTime>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return _SearchPanel(
                dates: snapshot.data!,
                selectedDate: _selectedDate!,
                onDateChanged: onDateChanged,
                onFilterPressed: onFilterPressed);
          }
          return SizedBox();
        });
  }

  _getCurrentLocation() {
    log("Retrieving current user location", name: TAG);
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium)
        .then((Position position) {
      log("Current user location is $position", name: TAG);
      if (this.mounted) {
        setState(() {
          _currentPosition = Coordinates(
              latitude: position.latitude, longitude: position.longitude);
        });
        if (_filter!.selectedPlace == Places.current && _selectedDate != null) {
          _retrieveWalks();
        }
      }
    }).catchError((e) {
      if (e is PlatformException) {
        PlatformException platformException = e;
        if (platformException.code == 'PERMISSION_DENIED') {
          PrefsProvider.prefs.setBoolean("use_location", false);
        }
      }
      print("Cannot retrieve current position: $e");
    });
  }
}

class _SearchPanel extends StatelessWidget {
  _SearchPanel(
      {required this.dates,
      required this.selectedDate,
      required this.onDateChanged,
      required this.onFilterPressed});

  final List<DateTime> dates;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final VoidCallback onFilterPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              DatesDropdown(
                  dates: dates,
                  selectedDate: selectedDate,
                  onChanged: onDateChanged),
              ActionChip(
                label: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Icon(Icons.tune, size: 16.0),
                    ),
                    Text("Filtres")
                  ],
                ),
                onPressed: onFilterPressed,
              ),
            ]));
  }
}
