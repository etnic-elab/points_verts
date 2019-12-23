import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:points_verts/walk.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class WalkList extends StatefulWidget {
  @override
  _WalkListState createState() => _WalkListState();
}

class _WalkListState extends State<WalkList> {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  List<DropdownMenuItem<String>> dropdownItems = _generateDropdownItems();
  List<Walk> _walks = List<Walk>();
  String _selectedDate = getNextSunday();
  Position _currentPosition;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    _getCurrentLocation();
    _retrieveWalks(_selectedDate);
    super.initState();
  }

  @override
  void reassemble() {
    _getCurrentLocation();
    _retrieveWalks(_selectedDate);
    super.reassemble();
  }

  Widget get _loadingView {
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }

  _retrieveWalks(String date) async {
    List<Walk> newList;
    if (date != _selectedDate || _walks.length == 0) {
      newList = List<Walk>();
      var response;
      try {
        response = await http.get(
            "https://www.am-sport.cfwb.be/adeps/pv_data.asp?type=map&dt=" +
                date +
                "&activites=M");
        var fixed = _fixCsv(response.body);
        List<List<dynamic>> rowsAsListOfValues =
            const CsvToListConverter(fieldDelimiter: ';').convert(fixed);
        for (List<dynamic> walk in rowsAsListOfValues) {
          newList.add(Walk(
              city: walk[1],
              province: walk[5],
              lat: walk[3],
              long: walk[4],
              date: walk[6]));
        }
      } catch (_) {
        setState(() {
          _selectedDate = date;
          _loading = false;
          _error = true;
        });
      }
    } else {
      newList = _walks;
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
      items: dropdownItems,
      onChanged: (String newValue) {
        setState(() {
          _loading = true;
          _error = false;
        });
        _retrieveWalks(newValue);
      },
    );
  }

  Widget _buildWalks() {
    var main = _defineMainPart();
    return Column(children: <Widget>[_dropdown(), new Expanded(child: main)]);
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


  static String getNextSunday() {
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
