import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'walks_view.dart';

void main() async {
  await DotEnv().load('.env');
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
      home: WalksView(),
    );
  }

  Widget _lightTheme() {
    return MaterialApp(
      title: 'Points Verts',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: WalksView(),
    );
  }

  Widget _darkTheme() {
    return MaterialApp(
      title: 'Points Verts',
      theme:
          ThemeData(brightness: Brightness.dark, primarySwatch: Colors.green),
      home: WalksView(),
    );
  }
}
