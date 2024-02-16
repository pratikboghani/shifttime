import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utilities/constants.dart';
import '../utilities/text_form_field_widget.dart';

void main() {
  runApp(UserSettingScreen());
}

Map<String, dynamic> userData = {};

class UserSettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: mytheme,
      home: Scaffold(
        body: SingleChildScrollView(
          child: UserInfoScreen(),
        ),
      ),
    );
  }
}

class UserInfoScreen extends StatefulWidget {
  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  @override
  void initState() {
    super.initState();
    fetchData('$apiPrefix/users/$userId').then((data) {
      setState(() {
        userData = data['response'];
      });
    }).catchError((error) {
      print('Error fetching data: $error');
      // Handle error, show a message, or take appropriate action
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: userData.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UserInfoCard(
                  title: 'Profile',
                  data: {
                    'First Name': userData['firstName'] ?? '',
                    'Last Name': userData['lastName'] ?? '',
                    'Email': userData['email'] ?? '',
                    'Gender': userData['gender'] ?? '',
                    'Username': userData['userName'] ?? '',
                    'Birth Date': userData['birthdate'] ?? '',
                    'Mobile Number': userData['mobile'].toString(),
                    'Client ID': userData['clientId'].toString(),
                  },
                ),
                SizedBox(height: 16),
                UserInfoCard(
                  title: 'Emergency Information',
                  data: {
                    'Emergency Contact':
                        userData['emergencyContactName'].toString(),
                    'Emergency Contact Number':
                        userData['emergencyContactNumber'].toString(),
                  },
                ),
                SizedBox(height: 16),
                UserInfoCard(
                  title: 'Password Information',
                  data: {
                    'Password': '********',
                  },
                ),
              ],
            )
          : CircularProgressIndicator(),
    );
  }
}

class UserInfoCard extends StatefulWidget {
  final String title;
  final Map<String, String> data;

  UserInfoCard({required this.title, required this.data});

  @override
  _UserInfoCardState createState() => _UserInfoCardState();
}

class _UserInfoCardState extends State<UserInfoCard> {
  late Map<String, TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = Map.fromEntries(
      widget.data.keys.map(
        (key) => MapEntry(key, TextEditingController(text: widget.data[key])),
      ),
    );
  }

  @override
  void dispose() {
    controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Divider(height: 16),
            ...widget.data.entries.map(
              (entry) => UserInfoItem(
                label: entry.key,
                value: entry.value,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showEditDialog(context, widget.title, widget.data);
                });
              },
              child: Text('Edit ${widget.title}'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, String title, Map<String, String> data) {
    controllers.forEach((key, controller) {
      controller.text = data[key] ?? '';
    });
    List<String> nonEditableFields = ['Username', 'Client ID'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ...data.entries
                    .where((entry) => !nonEditableFields.contains(entry.key))
                    .map(
                      (entry) => UserInfoEditableItem(
                    label: entry.key,
                    controller: controllers[entry.key]!,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                applyChanges();
                Navigator.of(context).pop();
              },
              child: Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  void applyChanges() async {
    final userId = userData['_id'];
    final authToken = userToken;
    print('User Id from update : $userId');
    try {
      final Map<String, String> updatedData = {};
      controllers.forEach((key, controller) {
        updatedData[mapKey(key)] = controller.text;
      });
      print(updatedData);
      final response = await http.put(
        Uri.parse('$apiPrefix/users/$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(updatedData),
      );
      print(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User updated successfully'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
        // Optional: Refresh UI or fetch updated data
        // fetchData('$apiPrefix/users/$userId').then((data) {
        //   setState(() {
        //     userData = data['response'];
        //   });
        // });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update user: ${response.statusCode}'),
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

class UserInfoEditableItem extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  UserInfoEditableItem({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormFieldWidget(
              controller: controller,
              labelText: label,
              hintText: 'enter your $label',
              maxLength: 100,
              keyboardType: TextInputType.text,
              validator: (String value) {
                if (value.isEmpty) {
                  return 'Email is required';
                }
              },
              icon: const Icon(null),
            ),
          ),
        ],
      ),
    );
  }
}

class UserInfoItem extends StatelessWidget {
  final String label;
  final String value;

  UserInfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}

String mapKey(String uiKey) {
  switch (uiKey) {
    case 'First Name':
      return 'firstName';
    case 'Last Name':
      return 'lastName';
    case 'Birth Date':
      return 'birthdate';
    case 'Mobile Number':
      return 'mobile';
    case 'Email':
      return 'email';
    case 'Gender':
      return 'gender';
    case 'Emergency Contact':
      return 'emergencyContactName';
    case 'Emergency Contact Number':
      return 'emergencyContactNumber';
    case 'Password':
      return 'password';
    default:
      return uiKey;
  }
}
