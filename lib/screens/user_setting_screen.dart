import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utilities/constants.dart';
import '../utilities/text_form_field_widget.dart';

void main() {
  runApp(UserSettingScreen());
}

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

class UserInfoScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UserInfoCard(
            title: 'Profile',
            data: {
              'First Name': 'Ankit',
              'Last Name': 'Maniya',
              'Email': 'ankit2024@gmail.com',
              'Gender': 'Male',
              'Username': '3jhplfuHPGBQ',
              'Birth Date': '',
              'Mobile Number': 'ankit2024@gmail.com',
              'Client ID': '3jhplfuHPGBQ',
            },
          ),
          SizedBox(height: 16),
          UserInfoCard(
            title: 'Emergency Information',
            data: {
              'Emergency Contact': 'Pratik',
              'Emergency Contact Number': '',
            },
          ),
          SizedBox(height: 16),
          UserInfoCard(
            title: 'Password Information',
            data: {
              'Password': '12345678',
            },
          ),
        ],
      ),
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
                _showEditDialog(context, widget.title, widget.data);
              },
              child: Text('Edit ${widget.title}'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, String title, Map<String, String> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ...data.entries.map(
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

  void applyChanges() {
    setState(() {
      widget.data.keys.forEach(
            (key) => widget.data[key] = controllers[key]!.text,
      );
    });
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
          // Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          // SizedBox(width: 8),
          Expanded(
            child: TextFormFieldWidget(
              controller: controller,
              labelText: label,
              hintText: 'enter your $label',
              maxLength:100,
              keyboardType: TextInputType.text,
              validator: (String value) {
                if (value.isEmpty) {
                  return 'Email is required';
                }
              }, icon: const Icon(null),
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
