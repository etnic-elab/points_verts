import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:geolocator/geolocator.dart';
import 'package:points_verts/models/news.dart';
import 'package:points_verts/models/walk_filter.dart';
import 'package:points_verts/models/weather.dart';
import 'package:points_verts/services/database.dart';
import 'package:points_verts/services/news.dart';
import 'package:points_verts/views/loading.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:points_verts/views/news.dart';
import 'package:points_verts/views/walks/filter_page.dart';

import 'dates_dropdown.dart';
import '../../models/walk.dart';
import 'walk_results_list_view.dart';
import 'walk_results_map_view.dart';
import 'walk_utils.dart';

enum Places { home, current }
enum _ViewType { list, map }

const String tag = "dev.alpagaga.points_verts.WalkList";

class WalksView extends StatefulWidget {
  const WalksView({Key? key}) : super(key: key);

  @override
  _WalksViewState createState() => _WalksViewState();
}

class _WalksViewState extends State<WalksView> with WidgetsBindingObserver {
  Future<List<DateTime>>? _dates;
  Future<List<Walk>>? _currentWalks;
  Walk? _selectedWalk;
  DateTime? _selectedDate;
  LatLng? _currentPosition;
  LatLng? _homePosition;
  _ViewType _viewType = _ViewType.list;
  WalkFilter? _filter;
  bool newsOpen = false;

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

  Future<void> _retrieveData() async {
    String? filterString =
        await PrefsProvider.prefs.getString(Prefs.calendarWalkFilter);
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

  void _retrieveDates() async {
    await _retrievePosition();
    _dates = DBProvider.db.getWalkDates();
    _dates!.then((List<DateTime> items) async {
      String? lastSelectedDateString =
          await PrefsProvider.prefs.getString(Prefs.lastSelectedDate);
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
            .setString(Prefs.lastSelectedDate, items.first.toIso8601String());
      }
      _retrieveWalks();
    }).catchError((err) {
      print("Cannot retrieve dates: $err");
      setState(() {
        _currentWalks = Future.error(err);
      });
    });
  }

  _retrievePosition() async {
    bool useLocation =
        await PrefsProvider.prefs.getBoolean(Prefs.useLocation) == true;
    _homePosition = await retrieveHomePosition();

    if (_filter!.selectedPlace == null) {
      if (_homePosition != null) {
        _filter!.selectedPlace = Places.home;
      } else if (useLocation) {
        _filter!.selectedPlace = Places.current;
      }
    } else if (_filter!.selectedPlace == Places.home && _homePosition == null) {
      if (useLocation) {
        _filter!.selectedPlace = Places.current;
      } else {
        _filter!.selectedPlace = null;
      }
    } else if (_filter!.selectedPlace == Places.current && !useLocation) {
      if (_homePosition != null) {
        _filter!.selectedPlace = Places.home;
      } else {
        _filter!.selectedPlace = null;
      }
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
    if (_filter!.selectedPlace == Places.current && _currentPosition == null) {
      await _retrieveCurrentPosition();
    }
    Future<List<Walk>> newList = retrieveSortedWalks(_selectedDate,
        filter: _filter, position: selectedPosition);
    try {
      _retrieveWeathers(await newList).then((_) {
        if (mounted) {
          setState(() {});
        }
      });
    } catch (err) {
      print("Cannot retrieve weather info: $err");
    }

    if (mounted) {
      setState(() {
        _currentWalks = newList;
      });
    }

    _firstLaunch();
    _news();
  }

  Future<void> _retrieveCurrentPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 4));
      _currentPosition = LatLng(position.latitude, position.longitude);
    } catch (e) {
      if (e is PlatformException) {
        PlatformException platformException = e;
        if (platformException.code == 'PERMISSION_DENIED') {
          PrefsProvider.prefs.setBoolean(Prefs.useLocation, false);
        }
      } else {
        _locationExceptionMessage();
      }

      print("Cannot retrieve current position: $e");
    }
  }

  Future _retrieveWeathers(List<Walk> walks) async {
    List<Future<List<Weather>>> weathers = [];
    for (int i = 0; i < math.min(walks.length, 5); i++) {
      Walk walk = walks[i];
      Future<List<Weather>> future = retrieveWeather(walk);
      future.then((weathers) {
        walk.weathers = weathers;
      });
      weathers.add(future);
    }
    return Future.wait(weathers);
  }

  void _firstLaunch() async {
    bool firstLaunch = await PrefsProvider.prefs
        .getBoolean(Prefs.firstLaunch, defaultValue: true);
    if (firstLaunch) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      final snackBar = SnackBar(
          duration: const Duration(days: 1),
          action: SnackBarAction(
            onPressed: () {
              PrefsProvider.prefs.setBoolean(Prefs.firstLaunch, false);
            },
            label: "OK",
          ),
          content: const Text(
              "Pour voir en un coup d'œil les marches les plus proches de chez vous, n'hésitez pas à indiquer votre adresse dans les Paramètres !",
              textAlign: TextAlign.justify));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _locationExceptionMessage() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    final snackBar = SnackBar(
        content: Row(
      children: const [
        Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: Icon(
            Icons.error,
            color: Colors.red,
          ),
        ),
        Flexible(
          child: Text(
            "Une erreur s'est produite lors de la récupération de votre position actuelle",
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _news() async {
    if (newsOpen == false) {
      List<dynamic> futures = await Future.wait(
          [PrefsProvider.prefs.getString(Prefs.news), retrieveNews()]);

      Set oldNews = futures[0] != null ? jsonDecode(futures[0]).toSet() : {};
      List<News> news = futures[1];

      int initialPage =
          news.indexWhere((News news) => !oldNews.contains(news.name));

      if (mounted && initialPage >= 0) {
        setState(() => newsOpen = true);
        Set<int> viewed = await showNews(context, news, initialPage);
        oldNews.addAll(viewed.map((int index) => news[index].name));
        await PrefsProvider.prefs
            .setString(Prefs.news, jsonEncode(oldNews.toList()));
        setState(() => newsOpen = false);
      }
    }
  }

  LatLng? get selectedPosition {
    if (_filter!.selectedPlace == Places.current) {
      return _currentPosition;
    } else if (_filter!.selectedPlace == Places.home) {
      return _homePosition;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier'),
        actions: <Widget>[
          IconButton(
            icon: Icon(_viewType == _ViewType.list ? Icons.map : Icons.list),
            onPressed: () {
              setState(() {
                _viewType = _viewType == _ViewType.list
                    ? _ViewType.map
                    : _ViewType.list;
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
          const Loading(),
          Container(
              padding: const EdgeInsets.all(10),
              child: const Text("Récupération des données..."))
        ],
      );
    }
    return Column(
      children: <Widget>[
        _defineSearchPart(dates),
        const Divider(height: 0.0),
        Expanded(
            child: _viewType == _ViewType.list
                ? WalkResultsListView(_currentWalks, selectedPosition,
                    _filter!.selectedPlace, _retrieveData)
                : WalkResultsMapView(
                    _currentWalks,
                    selectedPosition,
                    _filter!.selectedPlace,
                    _selectedWalk,
                    (Walk walk) {
                      setState(() {
                        _selectedWalk = walk;
                      });
                    },
                    () {
                      setState(() {
                        _selectedWalk = null;
                      });
                    },
                    _retrieveData,
                  )),
      ],
    );
  }

  void onDateChanged(DateTime date) {
    _selectedDate = date;
    _retrieveWalks();

    PrefsProvider.prefs
        .setString(Prefs.lastSelectedDate, date.toIso8601String());
  }

  void onFilterPressed() async {
    bool useLocation =
        await PrefsProvider.prefs.getBoolean(Prefs.useLocation) == true;
    WalkFilter? newFilter = await Navigator.of(context).push<WalkFilter>(
        MaterialPageRoute(
            builder: (context) =>
                FilterPage(_filter!, _homePosition != null && useLocation)));
    if (newFilter != null) {
      await PrefsProvider.prefs
          .setString(Prefs.calendarWalkFilter, jsonEncode(newFilter));
      _filter = newFilter;
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
          return const SizedBox();
        });
  }
}

class _SearchPanel extends StatelessWidget {
  const _SearchPanel(
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
                  children: const <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 4.0),
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
