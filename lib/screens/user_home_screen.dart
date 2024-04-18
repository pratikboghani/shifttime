import 'package:flutter/material.dart';
import 'package:shifttime/components/bookoff_form.dart';
import 'package:shifttime/screens/user_daywise_schedule_screen.dart';
import 'package:shifttime/screens/user_schedule_screen.dart';
import 'package:shifttime/screens/user_weekwise_schedule_screen.dart';
import 'package:shifttime/screens/user_setting_screen.dart';

import '../components/availability_form.dart';
import '../utilities/constants.dart';

void main() => runApp(const UserHomeScreen());

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: mytheme,
      home: const Navigation(),
    );
  }
}

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: clrGreenOriginal,
        title: Text(
          'ShiftTime',
          style: TextStyle(
              color: clrWhite,
              fontSize: 30,
              letterSpacing: 1,
              fontWeight: FontWeight.bold),
        ),
        leading: Image(
          image: const AssetImage('images/ShiftTimeIconWhite.png'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              firstName?? 'Guest',
              style: TextStyle(
                color: clrWhite,
                fontSize: 20,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
      body: <Widget>[
        /// Home page
        DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(text: 'My Shifts'),
                  Tab(text: "Today's Roster"),

                ],
              ),
              Expanded(
                  child: TabBarView(
                      children: [UserSchedule(), UserDayWiseSchedule(),])),
            ],
          ),
        ),

        /// Schedule page
        DefaultTabController(
          length: 3,
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(text: 'Bookoffs'),
                  Tab(text: 'Schedule'),
                  Tab(text: 'Availability'),
                ],
              ),
              Expanded(
                  child: TabBarView(
                      children: [BookoffForm(), UserWeekWiseSchedule(), AvailabilityForm()])),
            ],
          ),
        ),

        /// Settings menu
        UserSettingScreen(),
      ][currentPageIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: clrGreenOriginalLight,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: clrGreenOriginal,
        selectedIndex: currentPageIndex,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_rounded),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
