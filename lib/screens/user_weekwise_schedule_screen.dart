import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../utilities/constants.dart';

class UserWeekWiseSchedule extends StatefulWidget {
  const UserWeekWiseSchedule({Key? key}) : super(key: key);

  @override
  State<UserWeekWiseSchedule> createState() => _UserWeekWiseScheduleState();
}

class _UserWeekWiseScheduleState extends State<UserWeekWiseSchedule> {
  late DateTime _startOfWeek;
  late DateTime _endOfWeek;
  late List<Employee> employees;
  late Map<String, List<Employee>> categorizedEmployees;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  late List<dynamic> _shiftData = [];
  @override
  void initState() {
    super.initState();
    _calculateWeek(DateTime.now());
    employees = [];
    categorizedEmployees = {};
    _fetchEmployees();
    _fetchShiftDataByWeek();
  }

  void _calculateWeek(DateTime date) {
    final now = date;
    _startOfWeek = DateTime(now.year, now.month, now.day - now.weekday +1);
    _endOfWeek = _startOfWeek.add(Duration(days: 6));
    print('$_startOfWeek endofweek $_endOfWeek');
    _fetchShiftDataByWeek();
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
  bool hasShift(String employeeId, int dayIndex) {
    final DateTime day = _startOfWeek.add(Duration(days: dayIndex - 1));

    // Iterate through _shiftData to find if the employee has any shifts on the given day
    for (var shiftData in _shiftData) {
      // Iterate through each employee's shifts
      for (var employeeShift in shiftData['employees']) {
        if (employeeShift['_id']['userid'] == employeeId) {
          // Check if the shift falls on the given day
          final List<dynamic> shifts = employeeShift['shifts'];
          for (var shift in shifts) {
            final shiftDate = DateTime.parse(shift['start_date']).toLocal();
            if (shiftDate.year == day.year &&
                shiftDate.month == day.month &&
                shiftDate.day == day.day) {
              // If the employee has a shift on the given day, return true
              return true;
            }
          }
        }
      }
    }
    // If no shifts were found for the employee on the given day, return false
    return false;
  }

  Future<void> _fetchShiftDataByWeek() async {
    final String apiUrl =
        '$apiPrefix/shift/schedule-weekwise?startDate=${_dateFormat.format(_startOfWeek)}T00:00:00&endDate=${_dateFormat.format(_endOfWeek)}T24:00:00';

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
  Future<void> _fetchEmployees() async {
    final apiUrl = '$apiPrefix/users?query={"clientId": $clientId}';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> docs = responseData['response']['docs'];

      setState(() {
        employees = docs.map((json) => Employee.fromJson(json)).toList();
        _categorizeEmployees();
      });
    } else {
      // Handle error response
      print('Failed to fetch employees. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void _categorizeEmployees() {
    categorizedEmployees.clear();
    for (var employee in employees) {
      if (!categorizedEmployees.containsKey(employee.category)) {
        categorizedEmployees[employee.category ?? ""] = [];
      }
      categorizedEmployees[employee.category ?? ""]?.add(employee);
    }
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
                    style: TextStyle(fontSize: screenWidth<600?screenWidth/30:20),
                  ),
                  IconButton(
                    onPressed: _goToNextWeek,
                    icon: Icon(Icons.arrow_right),
                  ),
                ],
              ),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 8,
                children: [Container(),
                  ...List.generate(7, (index) {
                    final day = _startOfWeek.add(Duration(days: index));
                    return Container(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(DateFormat('EEE').format(day)),
                          Text(DateFormat('dd').format(day)),
                        ],
                      ),
                    );
                  }),
                  // Empty container for the employee name column
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: categorizedEmployees.length,
                  itemBuilder: (context, categoryIndex) {
                    final category = categorizedEmployees.keys.elementAt(categoryIndex);
                    final categoryEmployees = categorizedEmployees[category]!;

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(
                              category,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 8,
                              crossAxisSpacing: 4,
                              mainAxisSpacing: 4,
                            ),
                            itemCount: categoryEmployees.length * 8,
                            itemBuilder: (context, index) {
                              final employeeIndex = index ~/ 8;
                              final dayIndex = index % 8;
                              final employee = categoryEmployees[employeeIndex];

                              if (dayIndex == 0) {
                                return Container(
                                  margin: EdgeInsets.only(left: 8),
                                  child: Center(
                                    child: Text(
                                      '${employee.userName}',
                                      style: TextStyle(fontSize: screenWidth < 600 ? screenWidth / 70 : 11, fontWeight: FontWeight.bold,),
                                    ),
                                  ),
                                );
                              } else {
                                final hasShiftForDay = hasShift(employee.id, dayIndex);
                                return Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: hasShiftForDay ? clrGreenOriginal : clrGreenWhite70,
                                      border: Border.all(color: clrGreenOriginal),
                                    ),
                                  ),
                                );
                              }
                            },

                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: UserWeekWiseSchedule(),
  ));
}
class Employee {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String gender;
  final String role;
  final String userName;
  final String? category;

  Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.role,
    required this.userName,
    required this.category,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      gender: json['gender'],
      role: json['role'],
      userName: json['userName'],
      category: json['category'] ?? '',
    );
  }
}