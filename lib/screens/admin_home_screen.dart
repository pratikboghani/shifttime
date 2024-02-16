import 'package:flutter/material.dart';

import '../utilities/constants.dart';
import 'manage_emp_screen.dart';

void main() => runApp(const AdminHomeScreen());

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme:mytheme,
      home: SafeArea(child: const AdminHomePage()),
    );
  }
}

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int currentPageIndex = 0;
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Schedule',
      style: optionStyle,
    ),
    ManageEmpScreen(),
    Text(
      'Index 3: Settings',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(

      backgroundColor: clrGreenOriginal,
      appBar: AppBar(
        backgroundColor: clrGreenOriginal,
        title: Text('ShiftTime', style: TextStyle(color: clrWhite, fontSize: 30, letterSpacing: 1, fontWeight: FontWeight.bold),),
        // leading: Image(image: const AssetImage('images/ShiftTimeIconWhite.png'),),
      ),
      body: Container(
        height: height,
        decoration: const BoxDecoration(
          color: clrGreenWhite90,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(100.0),
          ),
        ),
        child: Center(
          child: _widgetOptions[_selectedIndex],
        ),
      ),
      drawer: Drawer(

        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: clrGreenOriginal,
              ),
              child: Text('Welcome Admin', style: TextStyle(color: clrWhite),),
            ),
            ListTile(
              title: const Text('Home'),
              selected: _selectedIndex == 0,
              onTap: () {
                // Update the state of the app
                _onItemTapped(0);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Shift Schedule'),
              selected: _selectedIndex == 1,
              onTap: () {
                // Update the state of the app
                _onItemTapped(1);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Manage Employee'),
              selected: _selectedIndex == 2,
              onTap: () {
                // Update the state of the app
                _onItemTapped(2);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Settings'),
              selected: _selectedIndex == 3,
              onTap: () {
                // Update the state of the app
                _onItemTapped(3);

                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),



    );
  }
}
