import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;

import 'recalculate_distances_button.dart';
import 'walk.dart';
import 'walk_results_list_view.dart';
import 'walk_results_map_view.dart';

class WalkList extends StatefulWidget {
  @override
  _WalkListState createState() => _WalkListState();
}

class _WalkListState extends State<WalkList> {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  final Widget _loadingWidget = Center(
    child: new CircularProgressIndicator(),
  );

  List<DropdownMenuItem<String>> _dropdownItems =
      new List<DropdownMenuItem<String>>();
  Map<String, List<Walk>> _allWalks = HashMap<String, List<Walk>>();
  List<Walk> _currentWalks = List<Walk>();
  Walk _selectedWalk;
  String _selectedDate;
  Position _currentPosition;
  bool _calculatingPosition = false;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    _retrieveDates();
    _getCurrentLocation();
    super.initState();
  }

  Future<List<Walk>> _retrieveWalks() async {
    if (_selectedDate == null) {
      setState(() {
        _loading = false;
      });
      return _currentWalks;
    }
    List<Walk> newList;
    if (_allWalks.containsKey(_selectedDate)) {
      newList = _allWalks[_selectedDate];
    } else {
      try {
        newList = await _retrieveWalksFromEndpoint();
        _allWalks.putIfAbsent(_selectedDate, () => newList);
      } catch (err) {
        setState(() {
          _error = true;
          _loading = false;
        });
        return newList;
      }
    }

    if (_currentPosition != null) {
      newList = await _calculateDistances(newList);
    }
    setState(() {
      _currentWalks = newList;
      _error = false;
      _loading = false;
    });
    return _currentWalks;
  }

  Future<List<Walk>> _retrieveWalksFromEndpoint() async {
    List<Walk> newList = List<Walk>();
    var response = await http.get(
        "https://www.am-sport.cfwb.be/adeps/pv_data.asp?type=map&dt=$_selectedDate&activites=M,O");
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
    return walks;
  }

  void _retrieveDates() async {
    _retrieveDatesFromWorker().then((List<DropdownMenuItem> items) {
      setState(() {
        _dropdownItems = items;
        _selectedDate = items.isNotEmpty ? items.first.value : _getNextSunday();
      });
      _retrieveWalks();
    }).catchError((err) {
      print(err);
      setState(() {
        _dropdownItems = _generateDropdownItems();
        _selectedDate = _getNextSunday();
      });
      _retrieveWalks();
    });
  }

  Future<List<DropdownMenuItem>> _retrieveDatesFromWorker() async {
    try {
      String url = "https://points-verts.tbo.workers.dev/";
      var response = await http.get(url);
      var dates = jsonDecode(response.body);
      List<DropdownMenuItem<String>> results =
          new List<DropdownMenuItem<String>>();
      await initializeDateFormatting("fr_FR", null);
      DateFormat dateFormat = new DateFormat("dd-MM-yyyy");
      DateFormat fullDate = DateFormat.yMMMMEEEEd("fr_BE");
      for (String date in dates) {
        DateTime dateTime = dateFormat.parse(date);
        results.add(new DropdownMenuItem<String>(
            value: date, child: new Text(fullDate.format(dateTime))));
      }
      return results;
    } catch (err) {
      print(err);
      return _retrieveDatesFromEndpoint();
    }
  }

  Future<List<DropdownMenuItem>> _retrieveDatesFromEndpoint() async {
    String url = "https://www.am-sport.cfwb.be/adeps/pv_data.asp?type=dates";
    var response = await http.get(url);
    var document = parse(response.body);
    List<DropdownMenuItem<String>> results =
        new List<DropdownMenuItem<String>>();
    for (dom.Element element in document.getElementsByTagName('option')) {
      String value = element.attributes['value'];
      if (value != '0') {
        results.add(new DropdownMenuItem<String>(
            value: value, child: new Text(element.innerHtml)));
      }
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Points Verts Adeps'),
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () {
                    setState(() {
                      _selectedDate = _dropdownItems.first.value;
                    });
                    _refreshWalks();
                  }),
              _positionAppBarActionButton(),
            ],
            bottom: TabBar(
              tabs: <Widget>[Tab(text: "LISTE"), Tab(text: "CARTE")],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              _buildTab(WalkResultsListView(_currentWalks, _loading)),
              _buildTab(WalkResultsMapView(
                  _currentWalks, _currentPosition, _loading, _selectedWalk,
                  (walk) {
                setState(() {
                  _selectedWalk = walk;
                });
              })),
            ],
          ),
        ));
  }

  Widget _buildTab(Widget tabContent) {
    return Column(
      children: <Widget>[
        _defineSearchPart(),
        Expanded(
                child: _error ? _errorWidget() : tabContent),
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

  Widget _positionAppBarActionButton() {
    if (_calculatingPosition) {
      return new IconButton(icon: Icon(Icons.my_location), onPressed: null);
    } else {
      return RecalculateDistancesButton(onPressed: () {
        _getCurrentLocation();
      });
    }
  }

  Widget _dropdown() {
    return DropdownButton<String>(
      value: _selectedDate,
      items: _dropdownItems,
      onChanged: (String newValue) {
        setState(() {
          _selectedDate = newValue;
        });
        _refreshWalks();
      },
    );
  }

  _defineSearchPart() {
    if (_dropdownItems.isNotEmpty) {
      return Container(
          margin: const EdgeInsets.only(left: 10, right: 10),
          child: Row(children: <Widget>[
            _dropdown(),
            Expanded(child: _resultNumber())
          ]));
    } else {
      return _loadingWidget;
    }
  }

  _resultNumber() {
    if (_currentWalks.length > 0 && !_loading) {
      return Align(
          alignment: Alignment.centerRight,
          child: Text("${_currentWalks.length.toString()} résultat(s)"));
    } else {
      return SizedBox.shrink();
    }
  }

  Future<List<Walk>> _refreshWalks({bool clearDate = false}) {
    if (clearDate) {
      _allWalks.remove(_selectedDate);
    }
    setState(() {
      _loading = true;
      _error = false;
      _currentWalks = new List<Walk>();
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
      print(e);
    });
  }

  static String _getNextSunday() {
    DateTime current = new DateTime.now();
    Duration oneDay = new Duration(days: 1);
    DateFormat dateFormat = new DateFormat("dd-MM-yyyy");
    while (current.weekday != DateTime.sunday) {
      current = current.add(oneDay);
    }
    return dateFormat.format(current);
  }

  static List<DropdownMenuItem<String>> _generateDropdownItems() {
    List<String> results = new List<String>();
    DateTime current = new DateTime.now();
    Duration oneDay = new Duration(days: 1);
    Duration aWeek = new Duration(days: 7);
    DateFormat dateFormat = new DateFormat("dd-MM-yyyy");
    while (current.weekday != DateTime.sunday) {
      current = current.add(oneDay);
    }
    while (results.length < 10) {
      results.add(dateFormat.format(current));
      current = current.add(aWeek);
    }
    return results.map((String value) {
      return new DropdownMenuItem<String>(
        value: value,
        child: new Text(value),
      );
    }).toList();
  }
}
