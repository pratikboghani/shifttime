import 'package:flutter/material.dart';
import 'package:shifttime/utilities/constants.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

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
  List<String> categories = [
    'All',
    'Category1',
    'Category2'
  ]; // Define your categories here
  String selectedCategory = 'All'; // Default selected category

  @override
  void initState() {
    super.initState();
    // Initialize employees and appointments here using API data
    employees = [
      Employee(id: '1', name: 'Pratik Boghani', category: 'Category1'),
      Employee(id: '2', name: 'b', category: 'Category2'),
      Employee(id: '3', name: 'c', category: 'Category1'),
      Employee(id: '4', name: 'd', category: 'Category2'),
      Employee(id: '5', name: 'e', category: 'Category1'),
      Employee(id: '6', name: 'f', category: 'Category2'),
      Employee(id: '7', name: 'g', category: 'Category1'),
      Employee(id: '8', name: 'h', category: 'Category2'),
      Employee(id: '9', name: 'i', category: 'Category1'),
    ];
    appointments = [];
    updateEmployeeStats();
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
                    ...categories.map((category) =>
                        DropdownMenuItem(child: Text(category), value: category))
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
                      final totalHours = totalHoursMap[employee.name] ?? 0;
                      final totalMinutes = totalMinutesMap[employee.name] ?? 0;
                      final totalShifts = totalShiftsMap[employee.name] ?? 0;
                      final isSelected = selectedEmployee == employee;
                      return GestureDetector(
                        onTap: () {
                          setSelectedEmployee(employee);
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          margin: EdgeInsets.symmetric(vertical: 4.0),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.green.withOpacity(0.3) : null,
                            border: Border.all(color: Colors.green),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                employee.name,
                                style: TextStyle(
                                  fontWeight:  FontWeight.bold
                                ),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                'Hours: ${totalHours}.${totalMinutes}, Shifts: $totalShifts',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
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
                    // allowedViews: const [
                    //   CalendarView.day,
                    //   CalendarView.week,
                    //   CalendarView.workWeek,
                    //   CalendarView.month,
                    //   CalendarView.timelineDay,
                    //   CalendarView.timelineWeek,
                    //   CalendarView.timelineWorkWeek,
                    // ],
                    showNavigationArrow: true,
                    showWeekNumber: true,
                    showDatePickerButton: true,
                    allowDragAndDrop: true,
                    allowAppointmentResize: true,
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

                      return GestureDetector(
                        onLongPress: () {
                          setState(() {
                            appointments.remove(appointment);
                            updateEmployeeStats();
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: appointment.color,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                employeeName,
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                '$hours:$minutes',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    },

                    onTap: (details) {
                      final employee = getSelectedEmployee();
                      final appointment = Appointment(
                        startTime: details.date!,
                        endTime: details.date!.add(Duration(hours: 1)),
                        subject: employee.name,
                        color: getRandomColor(),
                      );
                      setState(() {
                        appointments.add(appointment);
                        updateEmployeeStats();
                      });
                      final duration = appointment.endTime.difference(appointment.startTime);
                      final hours = duration.inHours;
                      final minutes = duration.inMinutes.remainder(60);
                      print("----------------On Tap------------------");
                      print('Employee Name: ${appointment.subject}');
                      print('Shift Start Time: ${appointment.startTime}');
                      print('Shift End Time: ${appointment.endTime}');
                      print('Shift Duration: $hours:$minutes');
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
                      print("----------------On Appoinment Resize------------------");
                      print('Employee Name: $employeeName');
                      print('Shift Start Time: ${appointment.startTime}');
                      print('Shift End Time: ${appointment.endTime}');
                      print('Shift Duration: ${appointment.endTime.difference(appointment.startTime)}');
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

  void setSelectedEmployee(Employee employee) {
    setState(() {
      selectedEmployee = employee;
    });
  }

  Employee getSelectedEmployee() {
    return selectedEmployee ?? employees.first;
  }

  Color getRandomColor() {
    return Colors
        .green; // Replace with your implementation to generate a random color
  }

  void updateEmployeeStats() {
    totalHoursMap.clear();
    totalMinutesMap.clear();
    totalShiftsMap.clear();

    for (var employee in employees) {
      int totalMinutes = 0;
      int totalShifts = 0;

      for (var appointment in appointments) {
        if (appointment.subject == employee.name) {
          totalMinutes +=
              appointment.endTime.difference(appointment.startTime).inMinutes;
          totalShifts++;
        }
      }

      totalHoursMap[employee.name] = totalMinutes ~/ 60;
      totalMinutesMap[employee.name] = totalMinutes % 60;
      totalShiftsMap[employee.name] = totalShifts;
    }

    setState(() {});
  }
}

class Employee {
  final String id;
  final String name;
  final String category;

  Employee({required this.id, required this.name, required this.category});
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource({required List<Appointment> appointments}) {
    this.appointments = appointments;
  }
}
