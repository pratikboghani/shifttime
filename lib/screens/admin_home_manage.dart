import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shifttime/screens/admin_availability_manage.dart';

import '../utilities/constants.dart';
import 'admin_bookoff_manage.dart';
import 'manage_emp_screen.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>>? userData;
  List<dynamic> availabilityList = [];
  List<dynamic> bookoffList = [];
  String showApproved = "Pending";
  @override
  void initState() {
    super.initState();
    fetchData();
    fetchAvailability();
    _fetchbookoff();
  }
  Future<void> _fetchbookoff() async {
    try {
      final http.Response response = await http.get(
        Uri.parse('$apiPrefix/bookoff?query=${_getQuery()}'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> docs = responseBody['response']['docs'];

        setState(() {
          bookoffList = docs;
        });
        print('----------');
        print(bookoffList);
      } else {
        print('Failed to fetch bookoffff. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching bookoff: $error');
    }
  }
  Future<void> fetchAvailability() async {
    try {
      final http.Response response = await http.get(
        Uri.parse('$apiPrefix/availability?query=${_getQuery()}'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> docs = responseBody['response']['docs'];
        setState(() {
          availabilityList = docs;
        });
        print('----------');
        print(availabilityList);
      } else {
        print('Failed to fetch availability. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching availability: $error');
    }
  }

  String _getQuery() {
    if (showApproved == "All") {
      return "{}";
    } else {
      return '{"isApproved": ${showApproved == "Approved"}}';
    }
  }
  Future<void> fetchData() async {
    final apiUrl = '$apiPrefix/users?query={"clientId": $clientId}';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic>? docs = responseData['response']['docs'];
      if (docs != null) { // Check if docs is not null
        setState(() {
          userData = List<Map<String, dynamic>>.from(docs);
        });
      }
      print('----------');
      print(userData);
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStatsCard(),
          SizedBox(width: 20), // Add spacing between cards
          _buildAvailabilityCard(),
          SizedBox(width: 20),
          _buildBookoffCard(),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    int totalEmployees = 0;
    Map<String, int> categoryStats = {};

    if (userData != null) {
      totalEmployees = userData!
          .where((user) => user['role'] == 'EMPLOYEE')
          .toList()
          .length;

      userData!.forEach((user) {
        final category = user['category'];
        categoryStats[category] = (categoryStats[category] ?? 0) + 1;
      });
    }

    return GestureDetector(
      // onTap: () {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => ManageEmpScreen()),  );
      // },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Card(
          child: Container(
            width: 200,
            height: 200,
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Total Employees: $totalEmployees',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
      
                if (categoryStats.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: categoryStats.entries
                        .map(
                          (entry) => Text(
                        '${entry.key}: ${entry.value}',
                        textAlign: TextAlign.center,
                      ),
                    )
                        .toList(),
                  )
                else
                  Text(
                    'No data available',
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildAvailabilityCard() {
    int pendingAvailabilityCount = availabilityList.length;

    return GestureDetector(
      // onTap: () {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => ManageAvailability()), );
      // },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Card(
          child: Container(
            width: 200,
            height: 200,
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Pending Availability: $pendingAvailabilityCount',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  _buildBookoffCard(){
    int pendingBookoffCount = bookoffList.length;

    return GestureDetector(
      // onTap: () {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => ManageBookoff()),  );
      // },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Card(
          child: Container(
            width: 200,
            height: 200,
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Pending Bookoffs: $pendingBookoffCount',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}
