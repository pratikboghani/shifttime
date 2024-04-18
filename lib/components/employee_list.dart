import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
    final apiUrl = '$apiPrefix/users?query={"clientId": $clientId}';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> docs = responseData['response']['docs'];

      setState(() {
        userData = List<Map<String, dynamic>>.from(docs);
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double listWidth = screenWidth < 600 ? screenWidth * 0.9 : 600;

    return Scaffold(
      body: Center(
        child: Container(
          width: listWidth,
          child: ListView.builder(
            itemCount: userData.length,
            itemBuilder: (context, index) {
              return UserCard(userData: userData[index]);
            },
          ),
        ),
      ),
    );
  }
}

class UserCard extends StatefulWidget {
  final Map<String, dynamic> userData;

  const UserCard({Key? key, required this.userData}) : super(key: key);

  @override
  _UserCardState createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _genderController;
  late TextEditingController _birthdateController;
  late TextEditingController _mobileController;
  late TextEditingController _emergencyContactNameController;
  late TextEditingController _emergencyContactNumberController;

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.userData['firstName']);
    _lastNameController =
        TextEditingController(text: widget.userData['lastName']);
    _emailController = TextEditingController(text: widget.userData['email']);
    _genderController = TextEditingController(text: widget.userData['gender']);
    _birthdateController =
        TextEditingController(text: widget.userData['birthdate']);
    _mobileController =
        TextEditingController(text: widget.userData['mobile'].toString());
    _emergencyContactNameController =
        TextEditingController(text: widget.userData['emergencyContactName']);
    _emergencyContactNumberController = TextEditingController(
        text: widget.userData['emergencyContactNumber'].toString());
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _genderController.dispose();
    _birthdateController.dispose();
    _mobileController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${widget.userData['firstName']} ${widget.userData['lastName']}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Email: ${widget.userData['email']}'),
                Text('Role: ${widget.userData['role']}'),
                Text('Gender: ${widget.userData['gender']}'),
                Text('Birthdate: ${widget.userData['birthdate']}'),
                Text('Mobile: ${widget.userData['mobile']}'),
                Text('Category: ${widget.userData['category']}'),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Edit User'),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: _firstNameController,
                                  decoration: const InputDecoration(
                                      labelText: 'First Name'),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _lastNameController,
                                  decoration: const InputDecoration(
                                      labelText: 'Last Name'),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                      labelText: 'Email'),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _genderController,
                                  decoration: const InputDecoration(
                                      labelText: 'Gender'),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _birthdateController,
                                  decoration: const InputDecoration(
                                      labelText: 'Birthdate'),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _mobileController,
                                  decoration: const InputDecoration(
                                      labelText: 'Mobile Number'),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _emergencyContactNameController,
                                  decoration: const InputDecoration(
                                      labelText: 'Emergency Contact Name'),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller:
                                  _emergencyContactNumberController,
                                  decoration: const InputDecoration(
                                      labelText: 'Emergency Contact Number'),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                // Call function to update user data
                                await _updateUser(context);
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: const Text('Update'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _showDeleteConfirmationDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUser(BuildContext context) async {
    final updatedUserData = {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'email': _emailController.text,
      'gender': _genderController.text,
      'birthdate': _birthdateController.text,
      'mobile': _mobileController.text,
      'emergencyContactName': _emergencyContactNameController.text,
      'emergencyContactNumber': _emergencyContactNumberController.text,
    };

    final userId = widget.userData['_id'];
    final authToken = userToken;

    try {
      final response = await http.put(
        Uri.parse('$apiPrefix/users/$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(updatedUserData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Text('Failed to update user: ${response.statusCode}'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: const Text('Are you sure you want to delete this user?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _deleteUser(context);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUser(BuildContext context) async {
    final userId = widget.userData['_id'];
    final authToken = userToken;
    try {
      final response = await http.delete(
        Uri.parse('$apiPrefix/users/$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User deleted successfully'),
            duration: Duration(seconds: 2),
          ),
        );
        // Optionally, you can update the UI or reload the data here
        // For example, you can call setState() to update the widget
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Text('Failed to delete user: ${response.statusCode}'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

