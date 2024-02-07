import 'package:flutter/material.dart';

import '../utilities/constants.dart';

void main() => runApp(const HomeScreen());

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text('ShiftTime', style: TextStyle(color: clrWhite),),
            floating: false,
            expandedHeight: 0,
            backgroundColor: clrGeenOriginal,

          ),
          SliverFillRemaining(
            child: <Widget>[
              /// Home page
              Card(
                shadowColor: Colors.transparent,
                margin: const EdgeInsets.all(8.0),
                child: SizedBox.expand(
                  child: Center(
                    child: Text(
                      'Home page',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                ),
              ),

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
                          color: theme.colorScheme.primary,
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
                        color: theme.colorScheme.primary,
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
            ][currentPageIndex],
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: clrGeenOriginal,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.notifications_sharp)),
            label: 'Notifications',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('2'),
              child: Icon(Icons.messenger_sharp),
            ),
            label: 'Messages',
          ),
        ],
      ),
    );
  }
}
