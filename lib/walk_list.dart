import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:points_verts/walk.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;

class WalkList extends StatefulWidget {
  @override
  _WalkListState createState() => _WalkListState();
}

class _WalkListState extends State<WalkList> {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  List<DropdownMenuItem<String>> _dropdownItems =
      new List<DropdownMenuItem<String>>();
  List<Walk> _walks = List<Walk>();
  String _selectedDate = _getNextSunday();
  Position _currentPosition;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    _getCurrentLocation();
    _retrieveDates();
    _retrieveWalks(_selectedDate);
    super.initState();
  }

  @override
  void reassemble() {
    _getCurrentLocation();
    _retrieveDates();
    _retrieveWalks(_selectedDate);
    super.reassemble();
  }

  Widget get _loadingView {
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }

  _retrieveWalks(String date) async {
    List<Walk> newList = List<Walk>();
      var response;
      try {
        response = await http.get(
            "https://www.am-sport.cfwb.be/adeps/pv_data.asp?type=map&dt=" +
                date +
                "&activites=M,O");
        var fixed = _fixCsv(response.body);
        List<List<dynamic>> rowsAsListOfValues =
            const CsvToListConverter(fieldDelimiter: ';').convert(fixed);
        for (List<dynamic> walk in rowsAsListOfValues) {
          newList.add(Walk(
              city: walk[1],
              type: walk[2],
              lat: walk[3],
              long: walk[4],
              province: walk[5],
              date: walk[6]));
        }
      } catch (_) {
        setState(() {
          _loading = false;
          _error = true;
        });
      }

    if (_currentPosition != null) {
      for (Walk walk in newList) {
        double distance = await geolocator.distanceBetween(
            _currentPosition.latitude,
            _currentPosition.longitude,
            walk.lat,
            walk.long);
        walk.distance = distance;
      }
      newList.sort((a, b) {
        return a.distance.compareTo(b.distance);
      });
    }
    setState(() {
      _selectedDate = date;
      _walks = newList;
      _loading = false;
      _error = false;
    });
  }

  _retrieveDates() {
    _retrieveDatesFromEndpoint().then((List<DropdownMenuItem> items) {
      setState(() {
        _dropdownItems = items;
        _selectedDate = items.isNotEmpty ? items.first.value : _getNextSunday();
      });
    }).catchError((_) {
      setState(() {
        _dropdownItems = _generateDropdownItems();
        _selectedDate = _getNextSunday();
      });
    });
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
      appBar: AppBar(
        title: Text('Points Verts Adeps'),
      ),
      body: _buildWalks(),
    );
  }

  Widget _dropdown() {
    return new DropdownButton<String>(
      value: _selectedDate,
      items: _dropdownItems,
      onChanged: (String newValue) {
        setState(() {
          _selectedDate = newValue;
          _loading = true;
          _error = false;
        });
        _retrieveWalks(newValue);
      },
    );
  }

  Widget _buildWalks() {
    var main = _defineMainPart();
    return Column(children: <Widget>[
      Center(child: _dropdown()),
      new Expanded(child: main)
    ]);
  }

  _defineMainPart() {
    if (_loading) {
      return _loadingView;
    } else if (_error) {
      return Text("An error occurred, please try again later.");
    } else {
      return ListView.separated(
          itemBuilder: (context, i) {
            if (_walks.length > i) {
              Walk walk = _walks[i];
              return ListTile(
                leading: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [_displayIcon(walk)]),
                title: Text(walk.city),
                subtitle: Text(walk.province),
                trailing: _displayDistance(walk),
                onTap: () => _launchMaps(walk),
              );
            } else {
              return ListTile();
            }
          },
          separatorBuilder: (context, i) {
            return new Divider();
          },
          itemCount: _walks.length);
    }
  }

  _displayIcon(walk) {
    if (walk.type == 'M') {
      return Icon(Icons.directions_walk);
    } else if (walk.type == 'O') {
      return Icon(Icons.map);
    } else {
      return Text('');
    }
  }

  _displayDistance(walk) {
    if (walk.distance != null) {
      return Text((walk.distance / 1000).round().toString() + " km");
    } else {
      return null;
    }
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
      _retrieveWalks(_selectedDate);
    }).catchError((e) {
      print(e);
    });
  }

  _launchMaps(Walk walk) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=${walk.lat},${walk.long}';
    String appleUrl = 'https://maps.apple.com/?sll=${walk..lat},${walk.long}';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else if (await canLaunch(appleUrl)) {
      await launch(appleUrl);
    }
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
