import 'dart:convert';
import 'dart:html';
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
  Map<String, List<Map<String, dynamic>>> availabilityMap = {};
  Map<String, List<List<String>>> availabilitySchedules = {};
  List<String> categories = ['All'];
  String selectedCategory = 'All'; // Default selected category
  DateTime currentDate = DateTime.now();

  late String weekNumberString = DateFormat('w').format(currentDate);
  late int weekNumber = int.parse(weekNumberString);
  late int year = currentDate.year;
  late Map<String, DateTime> weekDates = getWeekDates(weekNumber, year);
  late DateTime _weekStartDate = weekDates['start']!;
  late DateTime _weekEndDate = weekDates['end']!;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchEmployees();
    // Initialize employees and appointments here using API data
    employees = [];
    appointments = [];
    updateEmployeeStats();
    _fetchAvailability();
  }
  void _showSnackbar(String errorMessage, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
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
      List<String> fetchedCategories =
          docs.map((doc) => doc['category'] as String).toList();
      setState(() {
        categories.addAll(fetchedCategories);
      });
    } else {}
  }

  Future<void> _fetchEmployees() async {
    final apiUrl = '$apiPrefix/users?query={"clientId": $clientId}';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> docs = responseData['response']['docs'];

      setState(() {
        employees = docs.map((json) => Employee.fromJson(json)).toList();
      });

      // Fetch shifts from the API
      await _fetchShifts();
    } else {
      // Handle error response
      print('Failed to fetch employees. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }

    assignEmployeeColors();
  }

  Future<void> _fetchShifts() async {
    final apiUrl = '$apiPrefix/shift?query={"clientId": $clientId}';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> docs = responseData['response']['docs'];

      setState(() {
        appointments = docs.map((json) {
          final userId = json['userId'];
          final employee = employees.firstWhere((emp) => emp.id == userId,
              orElse: () => Employee(
                  id: '',
                  firstName: '',
                  lastName: '',
                  email: '',
                  gender: '',
                  role: '',
                  userName: '',
                  category: ''));
          final userName = employee.userName;
          final color = employeeColors[userName] ?? Colors.green;

          final startDateUtc = DateTime.parse(json['start_date']).toUtc();
          final endDateUtc = DateTime.parse(json['end_date']).toUtc();
          final startDate = startDateUtc.toLocal();
          final endDate = endDateUtc.toLocal();

          return Appointment(
            id: json['appointmentId'],
            startTime: startDate,
            endTime: endDate,
            subject: userName,
            color: color,
          );
        }).toList();
      });
    } else {
      // Handle error response
      print('Failed to fetch shifts. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> createShift(String userId, DateTime startDate, DateTime endDate,
      double duration, String appointmentId) async {
    final apiUrl = '$apiPrefix/shift/create';
    // Convert DateTime objects to UTC
    final startDateUtc = startDate.toUtc();
    final endDateUtc = endDate.toUtc();

    // Convert UTC DateTime objects to ISO 8601 format strings
    final startDateTimeString = startDateUtc.toIso8601String();
    final endDateTimeString = endDateUtc.toIso8601String();

    // Prepare the request body
    final Map<String, dynamic> requestBody = {
      'userId': userId,
      'clientId': clientId,
      'start_date': startDateTimeString,
      'end_date': endDateTimeString,
      'duration': duration.toString(),
      'appointmentId': appointmentId
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode(requestBody),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Shift created successfully
        print('Shift created successfully.');
      } else {
        // Handle error response
        print('Failed to create shift. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      // Handle network or other errors
      print('Error creating shift: $e');
    }
  }

  Future<void> _fetchAvailability() async {

    String apiUrl = '$apiPrefix/availability?query={"isApproved": true}';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic>? docs = responseData['response']['docs'];

      if (docs != null) {
        availabilitySchedules = {};
        //print('Docs: $docs');
        for (var doc in docs) {
          String userId = doc['userId'];
          List<dynamic>? availabilityDetails = doc['availibilityDetails'];

          if (availabilityDetails != null) {
            List<List<String>> userAvailability = [];
            for (var availabilityDetail in availabilityDetails) {
              String? dayOfWeek = availabilityDetail['day_of_week'];
              String? startTime = availabilityDetail['start_time'];
              String? endTime = availabilityDetail['end_time'];
              if (dayOfWeek != null && startTime != null && endTime != null) {
                userAvailability.add([dayOfWeek, startTime, endTime]);
              }
            }
            availabilitySchedules[userId] = userAvailability;
          }
        }
        availabilitySchedules = convertDataStructure(availabilitySchedules);
        print('User ID: $userId');
        print('Availability: ${availabilitySchedules}');
        print('===============================');
      }
    } else {
      // Handle error response
      print(
          'Failed to fetch availability. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> updateShiftByAppointmentId(
      String appointmentId, DateTime newStartDate, DateTime newEndDate) async {
    // Find the shift corresponding to the appointment ID
    final apiUrl = '$apiPrefix/shift?query={"appointmentId": "$appointmentId"}';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> docs = responseData['response']['docs'];
        if (docs.isNotEmpty) {
          final shiftId = docs[0]['_id'];
          final newStartDateUtc = newStartDate.toUtc();
          final newEndDateUtc = newEndDate.toUtc();
          // Update the shift with the new date, start time, and end time
          await updateShift(shiftId, newStartDateUtc, newEndDateUtc);
        } else {
          // Handle case where no shift is found for the appointment ID
          print('No shift found for appointment ID: $appointmentId');
        }
      } else {
        // Handle error response
        print(
            'Failed to fetch shift data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      // Handle network or other errors
      print('Error updating shift: $e');
    }
  }

  Future<void> updateShift(
      String shiftId, DateTime newStartDate, DateTime newEndDate) async {
    final apiUrl = '$apiPrefix/shift/$shiftId';
    // Convert DateTime objects to UTC
    final newStartDateUtc = newStartDate.toUtc();
    final newEndDateUtc = newEndDate.toUtc();

    // Convert UTC DateTime objects to ISO 8601 format strings
    final newStartDateTimeString = newStartDateUtc.toIso8601String();
    final newEndDateTimeString = newEndDateUtc.toIso8601String();

    // Prepare the request body
    final Map<String, dynamic> requestBody = {
      'start_date': newStartDateTimeString,
      'end_date': newEndDateTimeString,
      'duration':newEndDateUtc.difference(newStartDateUtc).inMinutes.toDouble(),
    };

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        body: json.encode(requestBody),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        // Shift updated successfully
        print('Shift updated successfully.');
      } else {
        // Handle error response
        print('Failed to update shift. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      // Handle network or other errors
      print('Error updating shift: $e');
    }
  }

  int parseHour(String timeString) {
    String hourString = timeString.split(':')[0];
    int hour = int.parse(hourString);
    if (timeString.contains('PM') && hour != 12) {
      hour += 12;
    } else if (timeString.contains('AM') && hour == 12) {
      hour = 0;
    }
    return hour;
  }
  Map<String, DateTime> getWeekDates(int weekNumber, int year) {
    DateTime januaryFirst = DateTime(year, 1, 1);
    int firstDayOfYear = januaryFirst.weekday;
    int daysToFirstThursday = (firstDayOfYear <= 4) ? 5 - firstDayOfYear : 12 - firstDayOfYear;
    DateTime firstThursday = januaryFirst.add(Duration(days: daysToFirstThursday));
    DateTime startOfWeek = firstThursday.add(Duration(days: (weekNumber - 1) * 7));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));
    return {'start': startOfWeek, 'end': endOfWeek};
  }
  Map<String, List<List<String>>> convertDataStructure(
      Map<dynamic, dynamic> originalData) {
    Map<String, List<List<String>>> convertedData = {};

    originalData.forEach((key, value) {
      List<List<String>> employeeAvailability = [];
      for (var slot in value) {
        List<String> slotString = [];
        slotString.add(
            "'${slot[0]}', '${slot[1]}', '${slot[2]}'"); // Enclosing each element in single quotation marks
        employeeAvailability.add(slotString);
      }
      convertedData["'$key'"] =
          employeeAvailability; // Enclosing key in single quotation marks
    });

    return convertedData;
  }

  Future<void> fetchShiftByAppointmentId(String appointmentId) async {
    final apiUrl = '$apiPrefix/shift?query={"appointmentId": "$appointmentId"}';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> docs = responseData['response']['docs'];
        if (docs.isNotEmpty) {
          final shiftId = docs[0]['_id'];
          // Call the deleteShift function with the shiftId
          await deleteShift(shiftId);
        } else {
          // Handle case where no shift is found for the appointment ID
          print('No shift found for appointment ID: $appointmentId');
        }
      } else {
        // Handle error response
        print(
            'Failed to fetch shift data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      // Handle network or other errors
      print('Error fetching shift data: $e');
    }
  }

  Future<void> deleteShift(String shiftId) async {
    final apiUrl = '$apiPrefix/shift/$shiftId';
    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );
      if (response.statusCode == 200) {
        // Shift deleted successfully
        print('Shift deleted successfully.');
      } else {
        // Handle error response
        print('Failed to delete shift. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      // Handle network or other errors
      print('Error deleting shift: $e');
    }
  }
  Future<void> publishShifts(DateTime startDate, DateTime endDate) async {
    endDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);

    final apiUrl = '$apiPrefix/shift/datewise?startDate=${startDate.toUtc().toIso8601String()}&endDate=${endDate.toUtc().toIso8601String()}';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        final List<dynamic> docs = responseData['response'];

        for (var doc in docs) {
          final List<dynamic> employees = doc['employees'];
          for (var employee in employees) {
            final String shiftId = employee['_id'];
            await updateShiftPublishStatus(shiftId, true);
          }
        }
      } else {
        // Handle error response
        print('Failed to publish shifts. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      // Handle network or other errors
      print('Error publishing shifts: $e');
    }
  }
  Future<void> updateShiftPublishStatus(String shiftId, bool isPublished) async {
    final apiUrl = '$apiPrefix/shift/$shiftId';

    // Prepare the request body
    final Map<String, dynamic> requestBody = {
      'isPublised': isPublished,
    };

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        body: json.encode(requestBody),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        // Shift publish status updated successfully
        print('Shift publish status updated successfully.');
      } else {
        // Handle error response
        print('Failed to update shift publish status. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      // Handle network or other errors
      print('Error updating shift publish status: $e');
    }
  }
  Future<void> _sendEmail(DateTime startDate, DateTime endDate) async {
    endDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);
      final apiUrl = '$apiPrefix/email/sentshiftdetails';
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'startDate': startDate.toUtc().toIso8601String(),
          'endDate': endDate.toUtc().toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        // Email sent successfully
        _showSnackbar('Shift Published and Email sent successfully.', clrGreenOriginal);
        print('Email sent successfully.');
      } else {
        _showSnackbar(
            'Failed to send email. Status code: ${response.statusCode}',
            Colors.red);
        // Handle error response
        print('Failed to send email. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
  }
  void showCustomMenu(BuildContext context, Offset offset) {
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromCenter(center: offset, width: 0, height: 0),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          child: Text('Custom Option 1'),
          onTap: () {
            // Handle custom option 1
          },
        ),
        PopupMenuItem(
          child: Text('Custom Option 2'),
          onTap: () {
            // Handle custom option 2
          },
        ),
        // Add more custom options as needed
      ],
    );
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
                      final totalMinutes =
                          totalMinutesMap[employee.userName] ?? 0;
                      final totalShifts =
                          totalShiftsMap[employee.userName] ?? 0;
                      final isSelected = selectedEmployee == employee;
                      return GestureDetector(
                        onTap: () {
                          setSelectedEmployee(employee);
                        },
                        onSecondaryTap: (){
                          print('second tapppppppppp');
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
firstDayOfWeek: 1,
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
                            final appointment = details.appointments?.first;
                            if (appointment != null) {
                              fetchShiftByAppointmentId(
                                  appointment.id.toString());
                              setState(() {
                                appointments.remove(appointment);
                                updateEmployeeStats();
                              });
                            }
                          },
                          onSecondaryTap: (){
                            print('right clickkkkkkkkkkkkk');
                          },
                          onSecondaryTapUp: (TapUpDetails details) {
                            // Show your custom menu options here
                            showCustomMenu(context, details.globalPosition);
                          },
                          onSecondaryTapDown: (TapDownDetails details) {
                            // Show your custom menu options here
                            showCustomMenu(context, details.globalPosition);
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



                    onTap: (details) async {
                      final selectedTime = details.date!;
                      final employee = getSelectedEmployee();
                      if (!await isEmployeeAvailable(
                          employee.id, selectedTime)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Employee is not available at this time'),
                          ),
                        );
                      } else if (doesEmployeeHaveShiftOnDay(
                          employee, selectedTime)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Employee already has a shift on this day'),
                          ),
                        );
                      } else {
                        print('Selected time on tap ${details.date}');
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
                        final duration = appointment.endTime
                            .difference(appointment.startTime);
                        final hours = duration.inHours;
                        final minutes = duration.inMinutes.remainder(60);
                        print("----------------onTap------------------");
                        print('Employee Name: ${appointment.subject}');
                        print('Shift Start Time: ${appointment.startTime}');
                        print('Shift End Time: ${appointment.endTime}');
                        print('Shift Duration: $hours:$minutes');
                        print('Shift Duration2: ${duration.inMinutes.toDouble()}');
                        await createShift(
                            employee.id,
                            appointment.startTime,
                            appointment.endTime,
                            duration.inMinutes.toDouble(),
                            appointment.id.toString());
                      }
                    },
                    onLongPress: (details) {
                      // final appointment = details.appointments?.first;
                      //
                      // setState(() {
                      //   appointments.remove(appointment);
                      //   updateEmployeeStats();
                      // });

                      // Delete the shift using API call
                    },
                    onViewChanged: (ViewChangedDetails viewChangedDetails) {
                      _weekStartDate = viewChangedDetails.visibleDates.first;
                      _weekEndDate = viewChangedDetails.visibleDates.last;
                    },
                    onAppointmentResizeEnd: (details) {
                      updateEmployeeStats();
                      final appointment = details.appointment;
                      final employeeName = appointment.subject;
                      final DateTime newStartDate = appointment.startTime!;
                      final DateTime newEndDate = appointment.endTime!;
                      final appointmentId = appointment.id.toString();
                      print(
                          'Selected time on onAppointmentResizeEnd ${newStartDate} and ${newEndDate}');

                      updateShiftByAppointmentId(
                          appointmentId, newStartDate, newEndDate);
                      print(
                          "----------------On Appoinment Resize------------------");
                      print('Employee Name: $employeeName');
                      print('Shift Start Time: ${appointment.startTime}');
                      print('Shift End Time: ${appointment.endTime}');
                      print(
                          'Shift Duration: ${appointment.endTime.difference(appointment.startTime)}');
                    },
                    onDragEnd:
                        (AppointmentDragEndDetails appointmentDragEndDetails) {
                      dynamic appointment =
                          appointmentDragEndDetails.appointment!;
                      CalendarResource? sourceResource =
                          appointmentDragEndDetails.sourceResource;
                      CalendarResource? targetResource =
                          appointmentDragEndDetails.targetResource;
                      DateTime? droppingTime =
                          appointmentDragEndDetails.droppingTime;
                      updateShiftByAppointmentId(appointment.id.toString(),
                          appointment.startTime, appointment.endTime);
                      print(
                          'Selected time on DragEnd ${appointment.startTime} and ${appointment.endTime}');
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          await publishShifts(_weekStartDate, _weekEndDate);
          print('${_weekStartDate} to $_weekEndDate');
          await _sendEmail(_weekStartDate, _weekEndDate);
        },
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

  DateTime _parseTime(String timeString) {
    // Replace non-breaking space characters with regular space characters
    timeString = timeString.replaceAll('\u00A0', ' ');

    // Split the time string into hours and minutes
    final parts = timeString.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(
        parts[1].split(' ')[0]); // Remove non-numeric characters like AM/PM

    // Convert to DateTime object with arbitrary date (January 1, 0000)
    return DateTime(0, 1, 1, hours, minutes);
  }

  DateTime resetDate(DateTime dateTime) {
    return DateTime(0, 1, 1, dateTime.hour, dateTime.minute, dateTime.second,
        dateTime.millisecond, dateTime.microsecond);
  }

  String getDayOfWeek(int day) {
    switch (day) {
      case 1:
        return 'MONDAY';
      case 2:
        return 'TUESDAY';
      case 3:
        return 'WEDNESDAY';
      case 4:
        return 'THURSDAY';
      case 5:
        return 'FRIDAY';
      case 6:
        return 'SATURDAY';
      case 7:
        return 'SUNDAY';
      default:
        return '';
    }
  }

  bool isEmployeeAvailable(String employeeId, DateTime dateTime) {
    print('$employeeId $dateTime');
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

      print(dayOfWeek.toUpperCase());
      print(getDayOfWeek(dateTime.weekday));

      // Check if the day of the week matches
      if (dayOfWeek.toUpperCase() == getDayOfWeek(dateTime.weekday)) {
        print('in loop');
        print(startTime);
        print(endTime);
        // Parse start and end times into DateTime objects
        final startDateTime = _parseTime(startTime);
        final endDateTime = _parseTime(endTime);
        print('start $startDateTime');
        print('end $endDateTime');

        print(dateTime.isAfter(startDateTime));
        print(dateTime.isBefore(endDateTime));
        print(dateTime);
        // Check if the current time is within the availability slot
        if (resetDate(dateTime).isAfter(startDateTime) &&
            resetDate(dateTime).isBefore(endDateTime)) {
          return true;
        }
      }
    }

    // If no availability slot matches, consider the employee as unavailable at this time
    return false;
  }

  List<TimeRegion> generateAvailabilityTimeRegions(Employee employee) {
    final List<TimeRegion> regions = [];
    final Map<String, List<List<int>>> availabilitySchedules = {
      '65ce5ef34b43922c57ba63dc': [
        // Example availability schedule for employee 1
        [DateTime.sunday, 9, 17],
        [DateTime.monday, 9, 17],
        [DateTime.tuesday, 9, 17],
      ],
      '65dee32db1a7216c77da57f7': [
        // Example availability schedule for employee 2
        [DateTime.wednesday, 16, 24],
        [DateTime.thursday, 16, 24],
        [DateTime.friday, 16, 24],
      ],
      // Add more availability schedules for other employees as needed
    };

    // Get the availability schedule for the selected employee
    final availabilitySchedule = availabilitySchedules[employee.id];

    if (availabilitySchedule != null) {
      for (final schedule in availabilitySchedule) {
        final dayOfWeek = schedule[0];
        final startTime = schedule[1];
        final endTime = schedule[2];

        // Generate time regions for available slots
        final availableRegion = TimeRegion(
          startTime: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            startTime,
            0,
          ),
          endTime: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            endTime,
            0,
          ),
          color: Colors.green.withOpacity(0.2), // Customize the color as needed
        );

        regions.add(availableRegion);
      }
    }

    return regions;
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

  Widget timeRegionBuilder(
      BuildContext context, TimeRegionDetails timeRegionDetails) {
    final selectedEmployee = getSelectedEmployee();
    final selectedTime = timeRegionDetails.date ?? DateTime.now();

    // Check if the selected employee is not available at this time
    if (selectedEmployee != null &&
        !isEmployeeAvailable(selectedEmployee.id, selectedTime)) {
      // Return a disabled container for unavailable time slots
      return Container(
        color: Colors.grey.withOpacity(0.5),
      );
    }

    // Your existing code for handling specific time regions
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

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource({required List<Appointment> appointments}) {
    this.appointments = appointments;
  }
}
class CustomAppointment {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String subject;
  final bool isPublished; // New property

  CustomAppointment({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.subject,
    required this.isPublished,
  });
}
