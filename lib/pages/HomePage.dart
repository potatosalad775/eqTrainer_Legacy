import 'package:flutter/material.dart';
import 'package:eqtrainer/pages/SessionPage.dart';
import 'package:eqtrainer/pages/PlaylistPage.dart';
import 'package:eqtrainer/pages/SettingsPage.dart';
import 'package:eqtrainer/globals.dart' as globals;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  // Selected BottomNavigationBar index
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final _pageList = [
    const SessionPage(),
    const PlaylistPage(),
    const SettingsPage()
  ];

  @override
  void initState() {
    globals.initFile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      color: Theme.of(context).colorScheme.background,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: _pageList[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            elevation: 1,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.play_circle),
                label: 'Session',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.queue_music),
                label: 'Playlist',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
            currentIndex: _selectedIndex,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            selectedItemColor: Theme.of(context).colorScheme.onPrimaryContainer,
            unselectedItemColor: Theme.of(context).colorScheme.outline,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}