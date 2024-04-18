import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shifttime/screens/admin_schedule_screen1.dart';
import 'package:shifttime/screens/login_screen.dart';
import 'package:shifttime/screens/user_setting_screen.dart';

import '../components/add_categories_form.dart';
import '../utilities/constants.dart';
import 'admin_availability_manage.dart';
import 'admin_bookoff_manage.dart';
import 'admin_home_manage.dart';
import 'admin_schedule_screen.dart';
import 'admin_sendemail_screen.dart';
import 'admin_setting_screen.dart';
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
  static  List<Widget> _widgetOptions = <Widget>[
    Home(),
    ScheduleManageScreen1(),
    ManageEmpScreen(),
    CategoryForm(),
    ManageAvailability(),
    ManageBookoff(),
    SendEmail(),
    AdminSettingScreen()
  ];
  void _logout(BuildContext context) async {
    // Clear user session
    await clearSessionData();

    // Navigate back to the login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
  Future<void> clearSessionData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear(); // Clears all stored data
  }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context), // Call logout function on button press
          ),
        ],
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
              child: Text('Admin', style: TextStyle(color: clrWhite),),
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
              title: const Text('Manage Categories'),
              selected: _selectedIndex == 3,
              onTap: () {
                // Update the state of the app
                _onItemTapped(3);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Manage Availability'),
              selected: _selectedIndex == 4,
              onTap: () {
                // Update the state of the app
                _onItemTapped(4);

                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Manage Bookoffs'),
              selected: _selectedIndex == 5,
              onTap: () {
                // Update the state of the app
                _onItemTapped(5);

                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Send eMail'),
              selected: _selectedIndex == 6,
              onTap: () {
                // Update the state of the app
                _onItemTapped(6);

                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Settings'),
              selected: _selectedIndex == 7,
              onTap: () {
                // Update the state of the app
                _onItemTapped(7);

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
