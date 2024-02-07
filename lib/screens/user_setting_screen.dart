import 'package:flutter/material.dart';

void main() {
  runApp(UserSettingScreen());
}

class UserSettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SingleChildScrollView(child: UserInfoScreen(),),
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

class UserInfoCard extends StatelessWidget {
  final String title;
  final Map<String, String> data;

  UserInfoCard({required this.title, required this.data});

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
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Divider(height: 16),
            ...data.entries.map((entry) => UserInfoItem(
              label: entry.key,
              value: entry.value,
            )),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Open edit window for this card
                _showEditDialog(context, title, data);
              },
              child: Text('Edit $title'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, String title, Map<String, String> data) {
    // TODO: Implement edit dialog
    // This is where you can create a dialog or a separate screen for editing the data.
    // You can use TextEditingController for text fields and other form elements.
    // After editing, update the data accordingly.
    // For simplicity, a placeholder message is shown here.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: Text('Placeholder for edit dialog'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
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
