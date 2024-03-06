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

  // Map to store fixed random color for each employee
  final Map<String, Color> employeeColors = {};
  List<Map<String, dynamic>> userData = []; // Assuming userData is a list of category data
  String? selectedCategory;
  @override
  void initState() {
    super.initState();
    _appointments = _getAppointments(employees);
    _fetchEmployees();
    _fetchCategories();
  }
  Future<void> _fetchCategories() async {
    String apiUrl = '$apiPrefix/category/?query={"clientId": $clientId}';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> docs = responseData['response']['docs'];
      setState(() {
        userData = List<Map<String, dynamic>>.from(docs);
      });
    } else {}
  }
  List<Employee> _getFilteredEmployees() {
    if (selectedCategory == null || selectedCategory == "All") {
      return employees;
    } else {
      // Filter employees based on selected category
      return employees.where((employee) => employee.category == selectedCategory).toList();
    }
  }

  Future<void> _fetchEmployees() async {
    const apiUrl = '$apiPrefix /users?query}';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> docs = responseData['response']['docs'];

      setState(() {
        employees = docs.map((json) => Employee.fromJson(json)).toList();

        // Generate and store fixed random color for each employee
        for (Employee employee in employees) {
          employeeColors[employee.userName] =
              _generateFixedRandomColor(employee.userName.hashCode);
        }
      });
    } else {
      // Handle error response
      print('Failed to fetch employees. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  List<Appointment> _getAppointments(List<Employee> employees) {
    return employees.map((employee) {
      final Color backgroundColor = employeeColors[employee.userName] ?? Colors.grey;
      final bool isLightColor = _isLightColor(backgroundColor);
      final Color textColor = isLightColor ? Colors.black : Colors.white;

      return Appointment(
        startTime: DateTime.now().subtract(Duration(days: 1)),
        endTime: DateTime.now().subtract(Duration(days: 1)),
        subject: '${employee.userName}',
        color: backgroundColor,
        notes: textColor.toString(), // Store text color in notes
      );
    }).toList();
  }

  bool _isLightColor(Color color) {
    // A simple heuristic to determine if the color is light or dark
    final luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance > 0.5;
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedCategory ?? "All",
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue;
                });
              },
              items: [
                DropdownMenuItem<String>(
                  value: "All",
                  child: Text("All"),
                ),
                for (Map<String, dynamic> category in userData)
                  DropdownMenuItem<String>(
                    value: category['category'],
                    child: Text(category['category']),
                  ),
              ],
            ),
          ),],),
          Expanded(
            child: Row(
              children: [
                // Left side column with employee information
                Container(
                  width: 100,
                  color: Colors.grey[200],
                  child: Column(

                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      for (Employee employee in _getFilteredEmployees())
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
    showNavigationArrow:true,
    showWeekNumber:true,
    showDatePickerButton:true,
                    timeSlotViewSettings: TimeSlotViewSettings(
                      timeInterval: Duration(hours: 1),
                    ),
                    viewHeaderStyle: ViewHeaderStyle(
                      dayTextStyle: TextStyle(color: Colors.black), // Set text color for day headers
                      dateTextStyle: TextStyle(color: Colors.black), // Set text color for date headers
                    ),
                    appointmentTextStyle: TextStyle(color: Colors.black), // Set text color for appointment text
                    onTap: (CalendarTapDetails details) {
                      // Handle tap on the calendar cells here
                      if (details.targetElement == CalendarElement.calendarCell && details.date != null) {
                        // Appointment appointment = details.appointments![0];
                        print(details.appointments);
                        print('Selected Date: ${details.date!}');
                        // print('Tapped on appointment - Employee: ${appointment.subject}, Time: ${appointment.startTime}');
                        // Create a new appointment when tapped on the calendar cell
                        _addAppointment(details.date!, selectedEmployee ?? '');
                      }
                    },
                    onLongPress: (CalendarLongPressDetails details) {
                      // Handle long press events here
                      if (details.targetElement == CalendarElement.appointment) {
                        Appointment appointment = details.appointments![0];
                        print('Long pressed on appointment - Employee: ${appointment.subject}, Time: ${appointment.startTime}');
                      }
                    },
                    onViewChanged: (ViewChangedDetails details) {
                      // Handle view changes (e.g., when an appointment is dragged and dropped)
                      // for (int i = 0; i < details.visibleDates.length; i++) {
                      //   Appointment appointment = details.visibleDates[i];
                      //   // Print the time duration, date, and employee for each appointment
                      //   print('Time Duration: ${appointment.endTime.difference(appointment.startTime)}');
                      //   print('Date: ${appointment.startTime}');
                      //   print('Employee: ${appointment.subject}');
                      // }
                    },
            
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeButton(Employee employee) {
    final Color color = employeeColors[employee.userName] ?? Colors.grey;
    final bool isSelected = selectedEmployee == employee.userName;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedEmployee = employee.userName;
        });
      },
      child: Container(
        width: 64, // Increased width to accommodate the border
        height: 64, // Increased height to accommodate the border
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: isSelected ? 4.0 : 0.0, // Larger border for selected employee
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
          child: Center(
            child: Text(
              employee.userName[0],
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white, // Adjusted text color
                fontSize: 18,
              ),
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
    // Use the fixed random color for the employee in appointments
    final Color color = employeeColors[employeeName] ?? Colors.grey;

    // Add a new appointment to the calendar
    setState(() {
      _appointments.add(
        Appointment(
          startTime: date,
          endTime: date.add(Duration(hours: 1)),
          subject: '$employeeName',
          color: color, // Use the fixed random color for the employee
        ),
      );
    });
  }

  // Generate a fixed random color based on the hash code
  Color _generateFixedRandomColor(int hashCode) {
    final Random random = Random(hashCode);
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
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
