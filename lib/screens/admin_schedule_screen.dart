import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'dart:convert';
import 'dart:math'; // Import the 'dart:math' library for generating random colors
import 'package:http/http.dart' as http;

import '../utilities/constants.dart';

class ScheduleManageScreen extends StatefulWidget {
  const ScheduleManageScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleManageScreen> createState() => _ScheduleManageScreenState();
}

class _ScheduleManageScreenState extends State<ScheduleManageScreen> {
  late List<Appointment> _appointments;
  List<Employee> employees = [];
  String? selectedEmployee;

  @override
  void initState() {
    super.initState();
    _appointments = _getAppointments();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    const apiUrl = '$apiPrefix /users?query}';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> docs = responseData['response']['docs'];

      setState(() {
        employees = docs.map((json) => Employee.fromJson(json)).toList();
      });
    } else {
      // Handle error response
      print('Failed to fetch employees. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  List<Appointment> _getAppointments() {
    // Simulated data for appointments
    return [
      Appointment(
        startTime: DateTime.now().subtract(Duration(days: 1)),
        endTime: DateTime.now().subtract(Duration(days: 1)),
        subject: 'Meeting 1',
        color: Colors.grey,
      ),
      Appointment(
        startTime: DateTime.now().add(Duration(hours: 1)),
        endTime: DateTime.now().add(Duration(hours: 2)),
        subject: 'Meeting 2',
        color: Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left side column with employee information
          Container(
            width: 80,
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (Employee employee in employees)
                  _buildEmployeeButton(employee),
              ],
            ),
          ),
          // Calendar view
          Expanded(
            child: SfCalendar(
              view: CalendarView.week,
              allowDragAndDrop: true,
              allowAppointmentResize: true,
              dataSource: _getCalendarDataSource(),
              timeSlotViewSettings: TimeSlotViewSettings(
                timeInterval: Duration(hours: 1),
              ),
              onTap: (CalendarTapDetails details) {
                // Handle tap on the calendar cells here
                if (details.targetElement == CalendarElement.calendarCell &&
                    details.date != null) {
                  // Create a new appointment when tapped on the calendar cell
                  _addAppointment(details.date!, selectedEmployee ?? '');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeButton(Employee employee) {
    // Generate a random color for each employee
    final Color randomColor = Color((Random().nextDouble() * 0xFFFFFF).toInt())
        .withOpacity(1.0);

    return GestureDetector(
      onTap: () {
        // Set the selected employee when an employee button is tapped
        setState(() {
          selectedEmployee = employee.userName;
        });
      },
      child: Container(
        width: 60,
        height: 60,
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selectedEmployee == employee.userName
              ? Colors.blue // Highlight selected employee
              : randomColor, // Assign a random color to the employee
        ),
        child: Center(
          child: Text(
            employee.userName[0],
            style: TextStyle(
              color: selectedEmployee == employee.userName
                  ? Colors.white
                  : Colors.black,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  _getCalendarDataSource() {
    return AppointmentDataSource(appointments: _appointments);
  }

  _addAppointment(DateTime date, String employeeName) {
    // Add a new appointment to the calendar
    setState(() {
      _appointments.add(
        Appointment(
          startTime: date,
          endTime: date.add(Duration(hours: 1)),
          subject: 'Meeting with $employeeName',
          color: Colors.grey, // You can customize the color as needed
        ),
      );
    });
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource({required List<Appointment> appointments}) {
    this.appointments = appointments;
  }
}

class Employee {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String gender;
  final String role;
  final String userName;
  final String category;

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
