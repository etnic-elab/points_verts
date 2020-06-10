import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'views/directory/walk_directory_view.dart';
import 'views/settings/settings.dart';
import 'views/walks/walks_view.dart';

class WalksHomeScreen extends StatefulWidget {
  @override
  _WalksHomeScreenState createState() => _WalksHomeScreenState();
}

class _WalksHomeScreenState extends State<WalksHomeScreen> {
  List<Widget> _pages = [WalksView(), WalkDirectoryView(), Settings()];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), title: Text("Calendrier")),
          const BottomNavigationBarItem(
              icon: Icon(Icons.import_contacts), title: Text("Annuaire")),
          const BottomNavigationBarItem(
              icon: Icon(Icons.settings), title: Text("Paramètres")),
        ],
      ),
      body: _pages[_selectedIndex],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
