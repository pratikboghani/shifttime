import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../utilities/constants.dart';

class UserSchedule extends StatefulWidget {
  const UserSchedule({Key? key}) : super(key: key);

  @override
  State<UserSchedule> createState() => _UserScheduleState();
}

class _UserScheduleState extends State<UserSchedule> {
  late List<dynamic> _shiftData = [];

  @override
  void initState() {
    super.initState();
    _fetchShiftData();
  }
  String formattedDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    String dayOfWeek = DateFormat('EEEE').format(date);
    String month = DateFormat('MMMM').format(date);
    String day = DateFormat('dd').format(date);
    return '$dayOfWeek, $month $day';
  }
  Future<void> _fetchShiftData() async {
    // Calculate start and end date
    DateTime now = DateTime.now().toUtc();
    DateTime startDate = DateTime.utc(now.year, now.month, now.day);
    DateTime endDate = startDate.add(Duration(days: 30));
    print('---------=====');
print(userId);
    final String apiUrl =
        '$apiPrefix/shift/employeewise?startDate=${DateFormat('yyyy-MM-ddTHH:mm:ss').format(startDate)}&endDate=${DateFormat('yyyy-MM-ddTHH:mm:ss').format(endDate)}&userId=$userId';

    final response = await http.get(Uri.parse(apiUrl));
    print(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _shiftData = json.decode(response.body)['response'];
        print(_shiftData);
      });
    } else {
      throw Exception('Failed to load shift data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth < 600 ? screenWidth * 0.8 : 540;
    return Scaffold(
      body: _shiftData.isEmpty
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Center(
            child: Container(
                    width: containerWidth,
              child: ListView.builder(
                      itemCount: _shiftData.length,
                      itemBuilder: (context, index) {
              return _buildShiftCard(_shiftData[index]);
                      },
                    ),
            ),
          ),
    );
  }

  Widget _buildShiftCard(dynamic data) {
    String date = formattedDate(data['_id']);
    List<dynamic> shifts = data['shifts'];

    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Column(
              children: shifts.map<Widget>((shift) {
                String firstName = shift['firstName'];
                DateTime startDate = DateTime.parse(shift['start_date']).toLocal();
                DateTime endDate = DateTime.parse(shift['end_date']).toLocal();
                String startTime = DateFormat('hh:mm a').format(startDate);
                String endTime = DateFormat('hh:mm a').format(endDate);
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(firstName),
                        Text(startTime),
                        Text(endTime),
                      ],
                    ),

                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: UserSchedule(),
  ));
}
