import 'package:flutter/material.dart';

import '../components/add_employee.dart';
import '../components/employee_list.dart';
import '../utilities/constants.dart';

void main() => runApp(const ManageEmpScreen());

class ManageEmpScreen extends StatelessWidget {
  const ManageEmpScreen({super.key});

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

      body: <Widget>[
        /// Employee List component
        EmployeeListPage(),
        /// Insert employee component
        AddEmployeeForm(),
        ] [currentPageIndex],

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
            selectedIcon: Icon(Icons.list_alt_rounded),
            icon: Icon(Icons.list_alt_rounded),
            label: 'Employee Info',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_box_outlined),
            label: 'Add Employee',
          ),

        ],
      ),
    );
  }
}
