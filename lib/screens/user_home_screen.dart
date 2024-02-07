import 'package:flutter/material.dart';
import 'package:shifttime/screens/user_setting_screen.dart';

import '../utilities/constants.dart';

void main() => runApp(const UserHomeScreen());

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
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
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: clrGreenOriginal,
        title: Text('ShiftTime', style: TextStyle(color: clrWhite, fontSize: 30, letterSpacing: 1, fontWeight: FontWeight.bold),),
        leading: Image(image: const AssetImage('images/ShiftTimeIconWhite.png'),),
      ),
      body: <Widget>[
      /// Notifications page
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Card(
              child: ListTile(
                leading: Icon(Icons.notifications_sharp),
                title: Text('Notification 1'),
                subtitle: Text('This is a notification'),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.notifications_sharp),
                title: Text('Notification 2'),
                subtitle: Text('This is a notification'),
              ),
            ),
          ],
        ),
      ),
      /// Messages page
      ListView.builder(
        reverse: true,
        itemCount: 2,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: clrGreenOriginal,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  'Hello',
                  style: theme.textTheme.bodyLarge!
                      .copyWith(color: theme.colorScheme.onPrimary),
                ),
              ),
            );
          }
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: clrGreenOriginal,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'Hi!',
                style: theme.textTheme.bodyLarge!
                    .copyWith(color: theme.colorScheme.onPrimary),
              ),
            ),
          );
        },
      ),
        /// Settings menu
        UserSettingScreen(),] [currentPageIndex],

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
            icon:Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
