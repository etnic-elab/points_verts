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

import 'nav_bar.dart';
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
  final Widget loading = Center(
    child: new CircularProgressIndicator(),
  );
  final Widget error = Row(children: [
    Expanded(
        child: Center(
            child:
                Text("Une erreur est survenue, merci de réessayer plus tard.")))
  ]);

  List<DropdownMenuItem<String>> _dropdownItems =
      new List<DropdownMenuItem<String>>();
  List<Walk> _walks = List<Walk>();
  String _selectedDate;
  Position _currentPosition;
  bool _loading = true;
  bool _error = false;
  int _index = 0;

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
      return _walks;
    }
    List<Walk> newList = List<Walk>();
    var response;
    try {
      response = await http.get(
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
    } catch (err) {
      print(err);
      setState(() {
        _loading = false;
        _error = true;
      });
      return newList;
    }

    if (_currentPosition != null) {
      for (Walk walk in newList) {
        if (walk.lat != null && walk.long != null) {
          double distance = await geolocator.distanceBetween(
              _currentPosition.latitude,
              _currentPosition.longitude,
              walk.lat,
              walk.long);
          walk.distance = distance;
        }
      }
      newList.sort((a, b) {
        if (a.distance != null && b.distance != null) {
          return a.distance.compareTo(b.distance);
        } else if (a.distance != null) {
          return -1;
        } else {
          return 1;
        }
      });
    }
    setState(() {
      _walks = newList;
      _loading = false;
      _error = false;
    });
    return _walks;
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
    return Scaffold(
      appBar: AppBar(title: Text('Points Verts Adeps'), actions: <Widget>[
        IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              setState(() {
                _selectedDate = _dropdownItems.first.value;
              });
              _refreshWalks();
            }),
        RecalculateDistancesButton(onPressed: () {
          _getCurrentLocation();
        }),
      ]),
      bottomNavigationBar: NavBar(
        onIconTap: (int index) {
          setState(() {
            _index = index;
          });
        },
      ),
      body: _buildWalks(),
    );
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

  Widget _buildWalks() {
    var main = _defineMainPart();
    return Column(
        children: <Widget>[_defineSearchPart(), Expanded(child: main)]);
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
      return loading;
    }
  }

  _resultNumber() {
    if (_walks.length > 0 && !_loading) {
      return Align(
          alignment: Alignment.centerRight,
          child: Text("${_walks.length.toString()} résultat(s)"));
    } else {
      return SizedBox.shrink();
    }
  }

  _defineMainPart() {
    if (_loading) {
      return loading;
    } else if (_error) {
      return error;
    } else {
      return RefreshIndicator(
          child: _displayMainPart(), onRefresh: () => _refreshWalks());
    }
  }

  _displayMainPart() {
    if(_index == 1) {
      return WalkResultsMapView(_walks, _currentPosition);
    } else {
      return WalkResultsListView(_walks);
    }
  }

  Future<List<Walk>> _refreshWalks() {
    setState(() {
      _loading = true;
      _error = false;
      _walks = new List<Walk>();
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
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
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
