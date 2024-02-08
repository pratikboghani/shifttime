import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shifttime/utilities/constants.dart';

class EmployeeListPage extends StatefulWidget {
  const EmployeeListPage({Key? key}) : super(key: key);

  @override
  State<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  List<Map<String, dynamic>> userData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('$apiPrefix/users'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> docs = responseData['response']['docs'];

      setState(() {
        userData = List<Map<String, dynamic>>.from(docs);
      });
    } else {
      print('Failed to fetch data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: userData.length,
        itemBuilder: (context, index) {
          return UserCard(userData: userData[index]);
        },
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final Map<String, dynamic> userData;

  UserCard({required this.userData});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${userData['firstName']} ${userData['lastName']}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Email: ${userData['email']}'),
                Text('Role: ${userData['role']}'),
                Text('Gender: ${userData['gender']}'),
                // Add more user data fields as needed
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    // Handle edit action
                    // Open an edit dialog or navigate to an edit screen
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    // Handle delete action
                    // Show a confirmation dialog and delete the user if confirmed
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
