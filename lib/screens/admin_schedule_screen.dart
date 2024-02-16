import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class ScheduleManageScreen extends StatefulWidget {
  const ScheduleManageScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleManageScreen> createState() => _ScheduleManageScreenState();
}

class _ScheduleManageScreenState extends State<ScheduleManageScreen> {
  late List<Appointment> _appointments;

  @override
  void initState() {
    super.initState();
    _appointments = _getAppointments();
  }

  List<Appointment> _getAppointments() {
    // Simulated data for appointments
    return [
      Appointment(
        startTime: DateTime.now().subtract(Duration(days: 1),),
        endTime: DateTime.now().subtract(Duration(days: 1)),
        subject: 'Meeting 1',
        color: Colors.blue,
      ),
      Appointment(
        startTime: DateTime.now().add(Duration(hours: 1)),
        endTime: DateTime.now().add(Duration(hours: 2)),
        subject: 'Meeting 2',
        color: Colors.green,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfCalendar(
        view: CalendarView.week,
        allowDragAndDrop: true,
        allowAppointmentResize: true,
        dataSource: _getCalendarDataSource(),
        timeSlotViewSettings: TimeSlotViewSettings(
          timeInterval: Duration(hours: 1),

          // allowAppointmentResizing: true,
          // allowAppointmentDrag: true,
        ),
      ),
    );
  }

  _getCalendarDataSource() {
    return AppointmentDataSource(appointments: _appointments);
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource({required List<Appointment> appointments}) {
    this.appointments = appointments;
  }
}
