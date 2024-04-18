import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../utilities/constants.dart';

class UserDayWiseSchedule extends StatefulWidget {
  const UserDayWiseSchedule({Key? key}) : super(key: key);

  @override
  State<UserDayWiseSchedule> createState() => _UserDayWiseScheduleState();
}

class _UserDayWiseScheduleState extends State<UserDayWiseSchedule> {
  late DateTime _startOfWeek;
  late DateTime _endOfWeek;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  late List<dynamic> _shiftData = [];
  DateTime? _selectedDate = DateTime.now().toUtc();

  @override
  void initState() {
    super.initState();
    _calculateWeek(DateTime.now().toUtc()); // Convert to UTC
    _fetchShiftDataByDay();
  }

  void _calculateWeek(DateTime date) {
    final now = date;
    _startOfWeek = DateTime.utc(now.year, now.month, now.day - now.weekday + 1); // Convert to UTC
    _endOfWeek = _startOfWeek.add(Duration(days: 6));
    _selectedDate = _startOfWeek; // Set selected date to the first day of the week
    _fetchShiftDataByDay();
    _onDateSelected(_selectedDate!); // Print selected date
  }

  void _goToPreviousWeek() {
    setState(() {
      _calculateWeek(_startOfWeek.subtract(Duration(days: 7)));
    });
  }

  void _goToNextWeek() {
    setState(() {
      _calculateWeek(_startOfWeek.add(Duration(days: 7)));
    });
  }

  Future<void> _fetchShiftDataByDay() async {
    final String apiUrl =
        '$apiPrefix/shift/schedule-datewise?startDate=${_dateFormat.format(_selectedDate!)}T00:00:00&endDate=${_dateFormat.format(_selectedDate!)}T23:59:59'; // Changed to 23:59:59

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      setState(() {
        _shiftData = json.decode(response.body)['response'];
        print(_shiftData);
      });
    } else {
      throw Exception('Failed to load shift data');
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _fetchShiftDataByDay();
    print('Selected Date: ${_dateFormat.format(date)}');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth < 600 ? screenWidth * 0.8 : 540;
    return Scaffold(
      body: Center(
        child: Container(
          width: containerWidth,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _goToPreviousWeek,
                    icon: Icon(Icons.arrow_left),
                  ),
                  Text(
                    '${DateFormat('MMM dd').format(_startOfWeek)} - ${DateFormat('MMM dd').format(_endOfWeek)}',
                    style: TextStyle(fontSize: screenWidth < 600 ? screenWidth / 30 : 20),
                  ),
                  IconButton(
                    onPressed: _goToNextWeek,
                    icon: Icon(Icons.arrow_right),
                  ),
                ],
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final day = _startOfWeek.add(Duration(days: index));
                    final bool isSelected = _selectedDate != null &&
                        _selectedDate!.year == day.year &&
                        _selectedDate!.month == day.month &&
                        _selectedDate!.day == day.day;
                    return GestureDetector(
                      onTap: () => _onDateSelected(day),
                      child: Container(
                        width: containerWidth / 7,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? clrGreenWhite70 : null,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(DateFormat('EEE').format(day)),
                            Text(DateFormat('dd').format(day)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _buildShiftCards(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildShiftCards() {
    if (_shiftData.isEmpty) {
      return [
        Card(
          margin: EdgeInsets.all(10),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'No shift available',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ];
    } else {
      List<Widget> cards = [];
      for (var shift in _shiftData) {
        String category = shift['_id'];
        List<dynamic> employees = shift['employees'];
        cards.add(Card(
          margin: EdgeInsets.all(10),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Column(
                  children: employees.map<Widget>((employee) {
                    String name = employee['firstName'];
                    DateTime startDate = DateTime.parse(employee['start_date']).toLocal();
                    DateTime endDate = DateTime.parse(employee['end_date']).toLocal();
                    String startTime = DateFormat('hh:mm a').format(startDate);
                    String endTime = DateFormat('hh:mm a').format(endDate);
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(name),
                            Text(startTime),
                            Text(endTime),
                          ],
                        ),
                         // Horizontal line
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ));
      }
      return cards;
    }
  }


}

void main() {
  runApp(MaterialApp(
    home: UserDayWiseSchedule(),
  ));
}
