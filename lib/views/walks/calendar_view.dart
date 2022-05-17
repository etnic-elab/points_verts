import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:points_verts/models/address_suggestion.dart';
import 'package:points_verts/models/view_type.dart';
import 'package:points_verts/models/walk_filter.dart';
import 'package:points_verts/models/weather.dart';
import 'package:points_verts/services/service_locator.dart';
import 'package:points_verts/services/exceptions.dart';
import 'package:points_verts/services/navigation.dart';
import 'package:points_verts/views/walks/filter.dart';
import 'package:points_verts/views/walks/sort_sheet.dart';
import 'package:points_verts/views/widgets/bottom_navigation_bar.dart';
import 'package:points_verts/views/widgets/loading.dart';
import 'package:points_verts/services/prefs.dart';
import 'package:points_verts/models/walk_sort.dart';
import 'package:points_verts/models/places.dart';
import 'package:points_verts/views/walks/calendar_list_view.dart';
import 'package:points_verts/views/walks/calendar_map_view.dart';
import 'package:points_verts/views/walks/data_error.dart';
import 'package:points_verts/views/widgets/snackbars.dart';

import '../../models/walk.dart';
import 'utils.dart';

const String tag = "dev.alpagaga.points_verts.WalkList";

class CalendarView extends StatefulWidget {
  const CalendarView({Key? key}) : super(key: key);

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

//TODO: make annuaire
//TODO: add news
//TODO: add firebase (crashlytics + in_app_messaging)
//TODO: change walkTile
//TODO: add bottom navigation

class _CalendarViewState extends State<CalendarView> {
  final ScrollController _scrollController = ScrollController();
  final double _filterBarHiddenOffset = 33.0;

  Future<List<DateTime>?> _dates = Future.value();
  Future<List<Walk>?> _walks = Future.value();
  LatLng? _currentPosition;
  LatLng? _homePosition;
  Walk? _selectedWalk;
  WalkFilter _filter = WalkFilter();
  SortBy _sortBy = SortBy.defaultValue();
  ViewType _currentView = ViewType.calendarList;
  bool _filterBarHidden = false;
  int? _results;
  Future? _searching;
  DateTime? _lastRefresh;

  @override
  void initState() {
    super.initState();
    initData();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initData() async {
    List<String?> prefsStrings = await Future.wait([
      prefs.getString(Prefs.calendarWalkFilter),
      prefs.getString(Prefs.calendarSortBy)
    ]);
    WalkFilter? filter = prefsStrings[0] != null
        ? WalkFilter.fromJson(jsonDecode(prefsStrings[0]!))
        : null;
    SortBy? sortBy = prefsStrings[1] != null
        ? SortBy.fromJson(jsonDecode(prefsStrings[1]!))
        : null;

    setState(() {
      _filter = filter ?? _filter;
      _sortBy = sortBy ?? _sortBy;
    });

    refreshData(force: true);
  }

  Future<void> refreshData({force = false}) async {
    if (force == false) {
      bool doRefresh = _lastRefresh == null ||
          const Duration(seconds: 30) <
              DateTime.now().difference(_lastRefresh!);
      if (!doRefresh) return;
    }

    try {
      await Future.wait([
        _updatePosition().catchError((_) {
          setState(() => _sortBy = SortBy.defaultValue());
          prefs.setString(Prefs.calendarSortBy, jsonEncode(_sortBy));
        }),
        _retrieveDates()
      ]);
      updateWalks();
      setState(() => _lastRefresh = DateTime.now());
    } catch (err) {
      print("Cannot retrieve dates: $err");
      _dates = Future.error(err);
    }
  }

  Future updateWalks() {
    _walks = _retrieveWalks();
    return _walks
        .then((walks) => setState(() => _results = walks!.length))
        .catchError((_) => setState(() => _results = null));
  }

  Future<int?> newSearch({WalkFilter? filter, SortBy? sortBy}) async {
    if (_searching != null) {
      await _searching;
      return newSearch(filter: filter, sortBy: sortBy);
    }

    // lock
    var completer = Completer();
    setState(() {
      _searching = completer.future;
    });
    try {
      if (sortBy?.position ?? false) {
        await _updatePosition(update: sortBy, requestHome: true);
      }

      setState(() {
        _filter = filter ?? _filter;
        _sortBy = sortBy ?? _sortBy;
      });
      if (filter != null) {
        prefs.setString(Prefs.calendarWalkFilter, jsonEncode(_filter));
      }
      if (sortBy != null) {
        prefs.setString(Prefs.calendarSortBy, jsonEncode(_sortBy));
      }

      await updateWalks();
    } catch (err) {
      print(err);
    }

    if (_currentView == ViewType.calendarList) scrollToTop();
    // unlock
    completer.complete();
    setState(() {
      _selectedWalk = null;
      _searching = null;
      _filterBarHidden = false;
    });

    return _results;
  }

  Future<void> _updatePosition({SortBy? update, requestHome = false}) async {
    SnackbarHandler.of(context).remove();
    SortBy sortBy = update ?? _sortBy;

    try {
      if (sortBy.position) {
        if (sortBy.type == SortType.currentPosition) {
          try {
            _currentPosition = await retrieveCurrentPosition();
          } catch (err) {
            throw PositionNotFoundException(
                "Une erreur est survenue lors de la récupération de votre position actuelle",
                error: err);
          }
        }

        if (sortBy.type == SortType.homePosition) {
          _homePosition = await retrieveHomePosition();
          if (_homePosition == null) {
            AddressSuggestion? address;
            if (requestHome) {
              address = await navigator.pushNamed(homeSelectRoute)
                  as AddressSuggestion?;
            }
            if (address == null) {
              throw PositionNotFoundException(
                  "Une erreur est survenue lors de la récupération de votre domicile");
            }
            _homePosition = LatLng(address.latitude, address.longitude);
          }
        }

        if (mounted) setState(() {});
      }
    } on PositionNotFoundException catch (err) {
      print(err.error);
      SnackbarHandler.of(context).showLocationException(err.message);
      rethrow;
    }
  }

  Future _retrieveDates() {
    _dates = db.getWalkDates();
    return _dates.then((List<DateTime>? dates) {
      if (dates!.isEmpty) throw ArgumentError.value(dates);
      if (!dates.contains(_filter.date)) {
        setState(() => _filter.date = dates.first);
      }
    });
  }

  Future<List<Walk>> _retrieveWalks() async {
    Future<List<Walk>> walks = retrieveSortedWalks(
        filter: _filter, sortBy: _sortBy, position: _position);
    try {
      _retrieveWeathers(await walks).whenComplete(() {
        if (mounted) setState(() {});
      });
    } catch (err) {
      print("Cannot retrieve weather info: $err");
    }

    return walks;
  }

  Future _retrieveWeathers(List<Walk> walks) async {
    List<Future<List<Weather>>> weathers = [];
    for (int i = 0; i < math.min(walks.length, 5); i++) {
      Walk walk = walks[i];
      Future<List<Weather>> future =
          retrieveWeather(walk).then((weather) => walk.weathers = weather);
      weathers.add(future);
    }
    await Future.wait(weathers);
  }

  void _scrollListener() {
    bool filterBarHidden = _scrollController.offset > _filterBarHiddenOffset;
    if (filterBarHidden != _filterBarHidden) {
      setState(() => _filterBarHidden = filterBarHidden);
    }
  }

  void scrollToTop() {
    if (_scrollController.hasClients) _scrollController.jumpTo(0.0);
  }

  LatLng? get _position {
    switch (_sortBy.type) {
      case SortType.homePosition:
        return _homePosition;
      case SortType.currentPosition:
        return _currentPosition;
      default:
        return null;
    }
  }

  Places? get _place {
    switch (_sortBy.type) {
      case SortType.homePosition:
        return Places.home;
      case SortType.currentPosition:
        return Places.current;
      default:
        return null;
    }
  }

  SortSheet get _sortSheet => SortSheet(_sortBy, sortUpdate, _currentView);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([_dates, _walks]),
      builder: (BuildContext context, AsyncSnapshot future) {
        if (future.hasError) {
          return Scaffold(
              bottomNavigationBar: const AppBottomNavigationBar(),
              body: DataError(() => refreshData(force: true)));
        }

        List<DateTime>? dates = future.data?[0];
        List<Walk>? walks = future.data?[1];
        if (dates == null || walks == null) {
          return const Scaffold(
              bottomNavigationBar: AppBottomNavigationBar(),
              body: LoadingText("Récupération des données..."));
        }

        return Scaffold(
          bottomNavigationBar: const AppBottomNavigationBar(),
          endDrawer: FilterDrawer(_filter, walks.length, filterUpdate),
          body: _currentView == ViewType.calendarList
              ? CalendarListView(
                  appBar: appBar(dates),
                  walks: walks,
                  refreshData: refreshData,
                  results: _results!,
                  scrollController: _scrollController,
                  searching: _searching,
                  sortSheet: _sortSheet,
                  filterBarHidden: _filterBarHidden,
                )
              : CalendarMapView(
                  appBar: appBar(dates),
                  unselectWalk: unselectWalk,
                  selectWalk: selectWalk,
                  place: _place,
                  position: _position,
                  searching: _searching,
                  selectedWalk: _selectedWalk,
                  sortSheet: _sortSheet,
                  walks: walks),
        );
      },
    );
  }

  Future<int?> filterUpdate(WalkFilter newFilter) {
    return newSearch(filter: newFilter);
  }

  Future<int?> sortUpdate(SortBy sortBy) {
    return newSearch(sortBy: sortBy).catchError((err) {
      print(err);
    });
  }

  Future dateUpdate(List<DateTime> allDates) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _filter.date!,
        selectableDayPredicate: (date) => allDates.contains(date),
        fieldLabelText: "Choix de la date",
        helpText: "Choix de la date",
        fieldHintText: "dd/mm/aaaa",
        errorInvalidText: "Pas de Point à la date choisie.",
        errorFormatText: "Format invalide.",
        firstDate: allDates.first,
        lastDate: allDates.last);
    if (pickedDate != null) {
      _filter.date = pickedDate;
      newSearch(filter: _filter);
    }
  }

  Widget appBar(List<DateTime> dates) {
    return _AppBar(
        dateUpdate: dateUpdate,
        dates: dates,
        selectedDate: _filter.date!,
        toggleView: updateViewType,
        viewType: _currentView);
  }

  void updateViewType() {
    setState(() => _currentView = _currentView == ViewType.calendarList
        ? ViewType.calendarMap
        : ViewType.calendarList);
  }

  void selectWalk(Walk newValue) {
    if (mounted) setState(() => _selectedWalk = newValue);
  }

  void unselectWalk() {
    if (mounted) setState(() => _selectedWalk = null);
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar(
      {required this.dates,
      required this.selectedDate,
      required this.dateUpdate,
      required this.toggleView,
      required this.viewType,
      Key? key})
      : super(key: key);

  final List<DateTime> dates;
  final Function(List<DateTime>) dateUpdate;
  final DateTime selectedDate;
  final Function() toggleView;
  final ViewType viewType;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      elevation: 8.0,
      pinned: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_today),
          splashRadius: Material.defaultSplashRadius / 1.5,
          tooltip: 'Choisir la date',
          onPressed: () => dateUpdate(dates),
        ),
        IconButton(
          splashRadius: Material.defaultSplashRadius / 1.5,
          icon: Icon(toggleViewIcon),
          tooltip: toggleViewTooltip,
          onPressed: toggleView,
        ),
      ],
      title: SizedBox(
        width: double.infinity,
        child: GestureDetector(
          child: Opacity(
            opacity: 0.8,
            child: Tooltip(
                child: Text(DateFormat.yMMMEd("fr_BE").format(selectedDate),
                    overflow: TextOverflow.ellipsis),
                message: 'La date sélectionnée'),
          ),
          onTap: () => dateUpdate(dates),
        ),
      ),
    );
  }

  IconData get toggleViewIcon {
    switch (viewType) {
      case ViewType.calendarList:
        return Icons.map;
      case ViewType.calendarMap:
        return Icons.list;
      default:
        return Icons.error;
    }
  }

  String get toggleViewTooltip {
    switch (viewType) {
      case ViewType.calendarList:
        return 'Visualiser la carte';
      case ViewType.calendarMap:
        return 'Visualiser la liste';
      default:
        return 'No tooltip for $viewType';
    }
  }
}
