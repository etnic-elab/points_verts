import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:geolocator/geolocator.dart';
import 'package:points_verts/models/walk_filter.dart';
import 'package:points_verts/services/database.dart';
import 'package:points_verts/views/list_header.dart';
import 'package:points_verts/views/loading.dart';
import 'package:points_verts/views/walks/place_select.dart';
import 'package:points_verts/services/prefs.dart';

import 'dates_dropdown.dart';
import '../../services/mapbox.dart';
import '../../services/openweather.dart';
import '../../models/walk.dart';
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
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<List<DateTime>> _dates;
  Future<List<Walk>> _currentWalks;
  Walk _selectedWalk;
  DateTime _selectedDate;
  Position _currentPosition;
  Position _homePosition;
  Places _selectedPlace;
  ViewType _viewType = ViewType.list;
  WalkFilter _filter;

  @override
  void initState() {
    initializeDateFormatting("fr_BE");
    _retrieveData();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _retrieveData(resetDate: false);
    }
  }

  void _firstLaunch() async {
    bool firstLaunch = await PrefsProvider.prefs
        .getBoolean(key: 'first_launch', defaultValue: true);
    if (firstLaunch) {
      _scaffoldKey.currentState.removeCurrentSnackBar();
      final snackBar = SnackBar(
          duration: Duration(days: 1),
          action: SnackBarAction(
            onPressed: () {
              PrefsProvider.prefs.setBoolean("first_launch", false);
              _scaffoldKey.currentState.hideCurrentSnackBar();
            },
            label: "OK",
          ),
          content: const Text(
              "Pour voir en un coup d'œil les marches les plus proches de chez vous, n'hésitez pas à indiquer votre adresse dans les Paramètres !",
              textAlign: TextAlign.justify));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  Future<void> _retrieveData({bool resetDate = true}) async {
    // initialize database here in case of migrations
    await DBProvider.db.database;
    String filterString = await PrefsProvider.prefs.getString("walk_filter");
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
    await updateWalks();
    _retrieveDates(resetDate: resetDate);
  }

  _retrievePosition() async {
    String homePos = await PrefsProvider.prefs.getString("home_coords");
    if (homePos != null) {
      List<String> split = homePos.split(",");
      setState(() {
        _homePosition = Position(
            latitude: double.parse(split[0]),
            longitude: double.parse(split[1]));
        _selectedPlace = Places.home;
      });
    } else {
      setState(() {
        _selectedPlace = Places.current;
      });
    }
    if (await PrefsProvider.prefs.getBoolean(key: "use_location") == true) {
      _getCurrentLocation();
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
    Future<List<Walk>> newList =
        DBProvider.db.getWalks(_selectedDate, filter: _filter);
    if (selectedPosition != null) {
      newList = _calculateDistances(await newList);
    } else {
      (await newList).sort((a, b) => sortWalks(a, b));
    }
    if (_selectedDate.difference(DateTime.now()).inDays < 5) {
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
  }

  Future<List<Walk>> _calculateDistances(List<Walk> walks) async {
    for (Walk walk in walks) {
      if (walk.lat != null && walk.long != null) {
        double distance = await geolocator.distanceBetween(
            selectedPosition.latitude,
            selectedPosition.longitude,
            walk.lat,
            walk.long);
        walk.distance = distance;
        walk.trip = null;
      }
    }
    walks.sort((a, b) => sortWalks(a, b));
    try {
      retrieveTrips(
              selectedPosition.longitude, selectedPosition.latitude, walks)
          .then((_) {
        walks.sort((a, b) => sortWalks(a, b));
        setState(() {});
      });
    } catch (err) {
      print("Cannot retrieve trips: $err");
    }
    return walks;
  }

  Future _retrieveWeathers(List<Walk> walks) async {
    List<Future> weathers = List<Future>();
    for (Walk walk in walks) {
      if (walk.weathers == null && !walk.isCancelled()) {
        walk.weathers = getWeather(walk.long, walk.lat, _selectedDate);
        weathers.add(walk.weathers);
      }
    }
    return Future.wait(weathers);
  }

  void _retrieveDates({bool resetDate = true}) async {
    _dates = DBProvider.db.getWalkDates();
    await _retrievePosition();
    _dates.then((List<DateTime> items) {
      if (resetDate || !items.contains(_selectedDate)) {
        setState(() {
          _selectedDate = items.first;
        });
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
      key: _scaffoldKey,
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
    if (_dates == null) {
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
        _defineSearchPart(),
        Expanded(
            child: _viewType == ViewType.list
                ? WalkResultsListView(_currentWalks, selectedPosition,
                    _selectedPlace, _retrieveData)
                : WalkResultsMapView(_currentWalks, selectedPosition,
                    _selectedPlace, _selectedWalk, (walk) {
                    setState(() {
                      _selectedWalk = walk;
                    });
                  }, _retrieveData)),
      ],
    );
  }

  Widget _defineSearchPart() {
    return Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              DatesDropdown(
                  dates: _dates,
                  selectedDate: _selectedDate,
                  onChanged: (DateTime date) {
                    setState(() {
                      _selectedDate = date;
                      _retrieveWalks();
                    });
                  }),
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
                onPressed: () async {
                  await showDialog<void>(
                    context: context,
                    barrierDismissible: false, // user must tap button!
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            title: Text('Filtres'),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  _homePosition != null &&
                                          _currentPosition != null
                                      ? PlaceSelect(
                                          currentPlace: _selectedPlace,
                                          onChanged: (Places place) {
                                            setState(() {
                                              _selectedPlace = place;
                                            });
                                          })
                                      : SizedBox.shrink(),
                                  Row(
                                    children: <Widget>[
                                      Checkbox(
                                          onChanged: (bool) {
                                            _filter.cancelledWalks = bool;
                                            setState(() {});
                                          },
                                          value: _filter.cancelledWalks),
                                      Text("Marches annulées")
                                    ],
                                  ),
                                  ListHeader("Restrictions"),
                                  Row(
                                    children: <Widget>[
                                      Checkbox(
                                          onChanged: (bool) {
                                            _filter.fifteenKm = bool;
                                            setState(() {});
                                          },
                                          value: _filter.fifteenKm),
                                      Text("Parcours suppl. de 15 km")
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Checkbox(
                                          onChanged: (bool) {
                                            _filter.wheelchair = bool;
                                            setState(() {});
                                          },
                                          value: _filter.wheelchair),
                                      Text("Accessible PMR")
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Checkbox(
                                          onChanged: (bool) {
                                            _filter.stroller = bool;
                                            setState(() {});
                                          },
                                          value: _filter.stroller),
                                      Text("Poussettes")
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Checkbox(
                                          onChanged: (bool) {
                                            _filter.extraOrientation = bool;
                                            setState(() {});
                                          },
                                          value: _filter.extraOrientation),
                                      Text("Orientation")
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Checkbox(
                                          onChanged: (bool) {
                                            _filter.guided = bool;
                                            setState(() {});
                                          },
                                          value: _filter.guided),
                                      Text("Balade guidée")
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Checkbox(
                                          onChanged: (bool) {
                                            _filter.extraWalk = bool;
                                            setState(() {});
                                          },
                                          value: _filter.extraWalk),
                                      Text("Parcours suppl. de 10 km")
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Checkbox(
                                          onChanged: (bool) {
                                            _filter.bike = bool;
                                            setState(() {});
                                          },
                                          value: _filter.bike),
                                      Text("Vélo")
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Checkbox(
                                          onChanged: (bool) {
                                            _filter.mountainBike = bool;
                                            setState(() {});
                                          },
                                          value: _filter.mountainBike),
                                      Text("VTT")
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Checkbox(
                                          onChanged: (bool) {
                                            _filter.waterSupply = bool;
                                            setState(() {});
                                          },
                                          value: _filter.waterSupply),
                                      Text("Ravitaillement")
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Checkbox(
                                          onChanged: (bool) {
                                            _filter.beWapp = bool;
                                            setState(() {});
                                          },
                                          value: _filter.beWapp),
                                      Text("BeWaPP")
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Checkbox(
                                          onChanged: (bool) {
                                            _filter.transport = bool;
                                            setState(() {});
                                          },
                                          value: _filter.transport),
                                      Text("Transports en commun")
                                    ],
                                  ),
                                  ListHeader("Provinces"),
                                  Row(
                                    children: <Widget>[
                                      Checkbox(
                                          onChanged: (bool) {
                                            _filter.brabantWallon = bool;
                                            setState(() {});
                                          },
                                          value: _filter.brabantWallon),
                                      Text("Brabant Wallon")
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Checkbox(
                                          onChanged: (bool) {
                                            _filter.hainautEst = bool;
                                            setState(() {});
                                          },
                                          value: _filter.hainautEst),
                                      Text("Hainaut Est")
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Checkbox(
                                          onChanged: (bool) {
                                            _filter.hainautOuest = bool;
                                            setState(() {});
                                          },
                                          value: _filter.hainautOuest),
                                      Text("Hainaut Ouest")
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Checkbox(
                                          onChanged: (bool) {
                                            _filter.liege = bool;
                                            setState(() {});
                                          },
                                          value: _filter.liege),
                                      Text("Liège")
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Checkbox(
                                          onChanged: (bool) {
                                            _filter.luxembourg = bool;
                                            setState(() {});
                                          },
                                          value: _filter.luxembourg),
                                      Text("Luxembourg")
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Checkbox(
                                          onChanged: (bool) {
                                            _filter.namur = bool;
                                            setState(() {});
                                          },
                                          value: _filter.namur),
                                      Text("Namur")
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              FlatButton(
                                child: const Text('Réinitialiser'),
                                onPressed: () {
                                  setState(() {
                                    _filter = WalkFilter();
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                              FlatButton(
                                child: const Text('Filtrer'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                  await PrefsProvider.prefs
                      .setString("walk_filter", jsonEncode(_filter));
                  _retrieveWalks();
                },
              ),
            ]));
  }

  _getCurrentLocation() {
    log("Retrieving current user location", name: TAG);
    geolocator
        .getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            locationPermissionLevel: GeolocationPermission.locationWhenInUse)
        .then((Position position) {
      log("Current user location is $position", name: TAG);
      if (this.mounted) {
        setState(() {
          _currentPosition = position;
        });
        if (_selectedPlace == Places.current && _selectedDate != null) {
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
