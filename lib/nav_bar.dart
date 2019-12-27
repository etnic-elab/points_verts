import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NavBar extends StatefulWidget {
  NavBar({Key key, this.onIconTap}) : super(key: key);

  final void Function(int) onIconTap;

  @override
  _NavBarState createState() => _NavBarState(onIconTap: onIconTap);
}

class _NavBarState extends State<NavBar> {
  _NavBarState({this.onIconTap});

  final void Function(int) onIconTap;

  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    onIconTap(index);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          title: Text('Liste'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          title: Text('Carte'),
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.amber[800],
      onTap: _onItemTapped,
    );
  }
}
