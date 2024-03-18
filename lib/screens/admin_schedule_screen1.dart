import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:http/http.dart' as http;
import '../utilities/constants.dart';

class ScheduleManageScreen1 extends StatefulWidget {
  const ScheduleManageScreen1({Key? key}) : super(key: key);

  @override
  State<ScheduleManageScreen1> createState() => _ScheduleManageScreen1State();
}

class _ScheduleManageScreen1State extends State<ScheduleManageScreen1> {
  late List<Employee> employees;
  late List<Appointment> appointments;
  Employee? selectedEmployee;
  Map<String, int> totalHoursMap = {};
  Map<String, int> totalMinutesMap = {};
  Map<String, int> totalShiftsMap = {};
  Map<String, Color> employeeColors = {}; // Map to store employee colors

  List<String> categories = ['All'];
  String selectedCategory = 'All'; // Default selected category

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchEmployees();
    // Initialize employees and appointments here using API data
    employees = [];
    appointments = [];
    updateEmployeeStats();
  }

  // Function to assign unique colors to each employee
  void assignEmployeeColors() {
    final random = Random();
    for (var employee in employees) {
      final int red = random.nextInt(56) + 200;
      final int green = random.nextInt(56) + 200;
      final int blue = random.nextInt(56) + 200;
      employeeColors[employee.userName] = Color.fromARGB(255, red, green, blue);
    }
  }
  Future<void> _fetchCategories() async {
    String apiUrl = '$apiPrefix/category/?query={"clientId": $clientId}';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> docs = responseData['response']['docs'];
      List<String> fetchedCategories = docs.map((doc) => doc['category'] as String).toList();
      setState(() {
        categories.addAll(fetchedCategories);
      });
    } else {}
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
    assignEmployeeColors();
  }

  @override
  Widget build(BuildContext context) {
    final filteredEmployees = selectedCategory == 'All'
        ? employees
        : employees
            .where((employee) => employee.category == selectedCategory)
            .toList();

    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: DropdownButton<String>(
                  value: selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                  items: [
                    ...categories.map((category) => DropdownMenuItem(
                        child: Text(category), value: category))
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side column with employee list
                Container(
                  width: 200,
                  padding: EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: filteredEmployees.length,
                    itemBuilder: (context, index) {
                      final employee = filteredEmployees[index];
                      final totalHours = totalHoursMap[employee.userName] ?? 0;
                      final totalMinutes = totalMinutesMap[employee.userName] ?? 0;
                      final totalShifts = totalShiftsMap[employee.userName] ?? 0;
                      final isSelected = selectedEmployee == employee;
                      return GestureDetector(
                        onTap: () {
                          setSelectedEmployee(employee);
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          margin: EdgeInsets.symmetric(vertical: 4.0),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.green
                                : employeeColors[employee.userName],
                            border: Border.all(
                              color: isSelected ? Colors.black : Colors.green,
                              width: isSelected ? 2.0 : 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${employee.firstName} ${employee.lastName}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                'Hours: ${totalHours}.${totalMinutes}, Shifts: $totalShifts',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Right side column with calendar view
                Expanded(
                  child: SfCalendar(
                    view: CalendarView.week,
                    showNavigationArrow: true,
                    showWeekNumber: true,
                    showDatePickerButton: true,
                    allowDragAndDrop: true,
                    allowAppointmentResize: true,
                    //specialRegions: _getTimeRegions(),
                    timeRegionBuilder: timeRegionBuilder,
                    dataSource:
                        AppointmentDataSource(appointments: appointments),
                    appointmentBuilder: (context, details) {
                      final appointment = details.appointments.first;
                      final employeeName = appointment.subject;
                      final duration =
                          appointment.endTime.difference(appointment.startTime);
                      final totalMinutes = duration.inMinutes;
                      final hours = totalMinutes ~/ 60;
                      final minutes = totalMinutes % 60;

                      return Tooltip(
                        message:
                            'Employee: $employeeName\nStart: ${DateFormat('hh:mm a').format(appointment.startTime)}\nEnd: ${DateFormat('hh:mm a').format(appointment.endTime)}\nDuration: $hours:$minutes',
                        child: GestureDetector(
                          onLongPress: () {
                            setState(() {
                              appointments.remove(appointment);
                              updateEmployeeStats();
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: employeeColors[employeeName],
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  employeeName,
                                  style: TextStyle(color: Colors.black),
                                ),
                                Text(
                                  '$hours:$minutes',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },



                    onTap: (details) {
                      final selectedTime = details.date!;
                      final employee = getSelectedEmployee();
                      if (!isEmployeeAvailable(employee.id, selectedTime)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Employee is not available at this time'),
                          ),
                        );
                      } else if (doesEmployeeHaveShiftOnDay(employee, selectedTime)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Employee already has a shift on this day'),
                          ),
                        );
                      } else {
                        final appointment = Appointment(
                          startTime: details.date!,
                          endTime: details.date!.add(Duration(hours: 1)),
                          subject: '${employee.userName}',
                          color: employeeColors[employee.userName] ??
                              Colors.green, // Use employee's assigned color
                        );
                        setState(() {
                          appointments.add(appointment);
                          updateEmployeeStats();
                        });
                        final duration =
                        appointment.endTime.difference(appointment.startTime);
                        final hours = duration.inHours;
                        final minutes = duration.inMinutes.remainder(60);
                        print("----------------onTap------------------");
                        print('Employee Name: ${appointment.subject}');
                        print('Shift Start Time: ${appointment.startTime}');
                        print('Shift End Time: ${appointment.endTime}');
                        print('Shift Duration: $hours:$minutes');
                      }
                    },
                    onLongPress: (details) {
                      final appointment = details.appointments?.first;
                      setState(() {
                        appointments.remove(appointment);
                        updateEmployeeStats();
                      });
                    },
                    onAppointmentResizeEnd: (details) {
                      updateEmployeeStats();
                      final appointment = details.appointment;
                      final employeeName = appointment.subject;
                      print(
                          "----------------On Appoinment Resize------------------");
                      print('Employee Name: $employeeName');
                      print('Shift Start Time: ${appointment.startTime}');
                      print('Shift End Time: ${appointment.endTime}');
                      print(
                          'Shift Duration: ${appointment.endTime.difference(appointment.startTime)}');
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Text('Publish'),
      ),
    );
  }
  // List<TimeRegion> _getTimeRegions() {
  //   final List<TimeRegion> regions = <TimeRegion>[];
  //   DateTime date = DateTime.now();
  //   regions.add(TimeRegion(
  //     startTime: DateTime(2020, 12, 15, 13, 0, 0),
  //     endTime: DateTime(2020, 12, 15, 14, 0, 0),
  //     enablePointerInteraction: true,
  //     color: Colors.grey.withOpacity(0.2),
  //     recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
  //     text: 'Lunch',
  //   ));
  //   regions.add(TimeRegion(
  //     startTime: DateTime(2020, 12, 15, 00, 0, 0),
  //     endTime: DateTime(2020, 12, 15, 24, 0, 0),
  //     recurrenceRule: 'FREQ=WEEKLY;INTERVAL=1;BYDAY=SAT,SUN',
  //     color: Color(0xffbD3D3D3),
  //     text: 'WeekEnd',
  //   ));
  //   return regions;
  // }
  bool isEmployeeAvailable(String employeeId, DateTime dateTime) {
    // Define the availability schedules for each employee
    final Map<String, List<List<int>>> availabilitySchedules = {
      '1': [
        // Sunday, Monday, Tuesday: 9am - 5pm
        [DateTime.sunday, 9, 17],
        [DateTime.monday, 9, 17],
        [DateTime.tuesday, 9, 17],
      ],
      '2': [
        // Wednesday, Thursday, Friday: 4pm - 12am
        [DateTime.wednesday, 16, 24],
        [DateTime.thursday, 16, 24],
        [DateTime.friday, 16, 24],
      ],
      // Add more availability schedules for other employees as needed
    };

    // Check if the employeeId exists in the availability schedules
    if (!availabilitySchedules.containsKey(employeeId)) {
      // If the employeeId is not found, consider the employee as always available
      return true;
    }

    // Get the availability schedule for the employee
    final availabilitySchedule = availabilitySchedules[employeeId];

    // Check if the dateTime falls within any of the availability slots
    for (final schedule in availabilitySchedule!) {
      final dayOfWeek = schedule[0];
      final startTime = schedule[1];
      final endTime = schedule[2];

      // Check if the day of the week matches and the time falls within the range
      if (dateTime.weekday == dayOfWeek &&
          dateTime.hour >= startTime &&
          dateTime.hour < endTime) {
        return true;
      }
    }

    // If no availability slot matches, consider the employee as unavailable at this time
    return false;
  }

  void setSelectedEmployee(Employee employee) {
    setState(() {
      selectedEmployee = employee;
    });
  }

  Employee getSelectedEmployee() {
    return selectedEmployee ?? employees.first;
  }

  void updateEmployeeStats() {
    totalHoursMap.clear();
    totalMinutesMap.clear();
    totalShiftsMap.clear();

    for (var employee in employees) {
      int totalMinutes = 0;
      int totalShifts = 0;

      for (var appointment in appointments) {
        if (appointment.subject == employee.userName) {
          totalMinutes +=
              appointment.endTime.difference(appointment.startTime).inMinutes;
          totalShifts++;
        }
      }

      totalHoursMap[employee.userName] = totalMinutes ~/ 60;
      totalMinutesMap[employee.userName] = totalMinutes % 60;
      totalShiftsMap[employee.userName] = totalShifts;
    }

    setState(() {});
  }
  bool doesEmployeeHaveShiftOnDay(Employee employee, DateTime selectedDay) {
    for (var appointment in appointments) {
      if (appointment.subject == employee.userName &&
          appointment.startTime.year == selectedDay.year &&
          appointment.startTime.month == selectedDay.month &&
          appointment.startTime.day == selectedDay.day) {
        return true;
      }
    }
    return false;
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


class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource({required List<Appointment> appointments}) {
    this.appointments = appointments;
  }
}
Widget timeRegionBuilder(
    BuildContext context, TimeRegionDetails timeRegionDetails) {
  if (timeRegionDetails.region.text == "Lunch") {
    return Container(
      color: timeRegionDetails.region.color,
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant,
        color: Colors.grey.withOpacity(0.5),
      ),
    );
  } else if (timeRegionDetails.region.text == "WeekEnd") {
    return Container(
      color: timeRegionDetails.region.color,
      alignment: Alignment.center,
      child: Icon(
        Icons.weekend,
        color: Colors.grey.withOpacity(0.5),
      ),
    );
  }
  return Container();
}
