import 'package:flutter/material.dart';
import 'package:points_verts/walk_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(new MyApp(theme: prefs.getString("theme")));
}

class MyApp extends StatelessWidget {
  MyApp({this.theme});

  final String theme;

  @override
  Widget build(BuildContext context) {
    if (theme == "light") {
      return _lightTheme();
    } else if (theme == "dark") {
      return _darkTheme();
    } else {
      return _defaultTheme();
    }
  }

  Widget _defaultTheme() {
    return MaterialApp(
      title: 'Points Verts',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      darkTheme:
          ThemeData(brightness: Brightness.dark, primarySwatch: Colors.green),
      home: WalkList(),
    );
  }

  Widget _lightTheme() {
    return MaterialApp(
      title: 'Points Verts',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: WalkList(),
    );
  }

  Widget _darkTheme() {
    return MaterialApp(
      title: 'Points Verts',
      theme:
          ThemeData(brightness: Brightness.dark, primarySwatch: Colors.green),
      home: WalkList(),
    );
  }
}
