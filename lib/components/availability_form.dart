import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shifttime/utilities/constants.dart';
import 'package:shifttime/utilities/raised_button_widget.dart';
import 'package:shifttime/utilities/time_picker.dart';

import '../models/availabilityDetails.dart';

class AvailabilityForm extends StatefulWidget {
  const AvailabilityForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AvailabilityFormState createState() => _AvailabilityFormState();
}

class _AvailabilityFormState extends State<AvailabilityForm> {
  final TextEditingController sundayFController = TextEditingController();
  final TextEditingController sundayTController = TextEditingController();
  final TextEditingController mondayFController = TextEditingController();
  final TextEditingController mondayTController = TextEditingController();
  final TextEditingController tuesdayFController = TextEditingController();
  final TextEditingController tuesdayTController = TextEditingController();
  final TextEditingController wednesdayFController = TextEditingController();
  final TextEditingController wednesdayTController = TextEditingController();
  final TextEditingController thursdayFController = TextEditingController();
  final TextEditingController thursdayTController = TextEditingController();
  final TextEditingController fridayFController = TextEditingController();
  final TextEditingController fridayTController = TextEditingController();
  final TextEditingController saturdayFController = TextEditingController();
  final TextEditingController saturdayTController = TextEditingController();
  List<dynamic> availabilityList = [];
  String IsAvailable(String startTime, String endTime){
    if(startTime.isEmpty || endTime.isEmpty){
      return 'UNAVAILABLE';
    }
    return 'AVAILABLE';
  }
  Future<void> _saveAvailability() async {
    final List<AvailabilityDetails> availabilityDetailsList = [
      AvailabilityDetails(
        dayOfWeek: 'SUNDAY',
        startTime: sundayFController.text,
        endTime: sundayTController.text,
        availabilityType: IsAvailable(sundayFController.text,sundayTController.text),
      ),
      AvailabilityDetails(
        dayOfWeek: 'MONDAY',
        startTime: mondayTController.text,
        endTime: mondayFController.text,
        availabilityType: IsAvailable(mondayTController.text,mondayFController.text),
      ),
      AvailabilityDetails(
        dayOfWeek: 'TUESDAY',
        startTime: tuesdayFController.text,
        endTime: tuesdayTController.text,
        availabilityType: IsAvailable(tuesdayFController.text,tuesdayTController.text),
      ),
      AvailabilityDetails(
        dayOfWeek: 'WEDNESDAY',
        startTime: wednesdayFController.text,
        endTime: wednesdayTController.text,
        availabilityType: IsAvailable(wednesdayFController.text,wednesdayTController.text),
      ),
      AvailabilityDetails(
        dayOfWeek: 'THURSDAY',
        startTime: thursdayFController.text,
        endTime: thursdayTController.text,
        availabilityType: IsAvailable(thursdayFController.text,thursdayTController.text),
      ),
      AvailabilityDetails(
        dayOfWeek: 'FRIDAY',
        startTime: fridayFController.text,
        endTime: fridayTController.text,
        availabilityType: IsAvailable(fridayFController.text,fridayTController.text),
      ),
      AvailabilityDetails(
        dayOfWeek: 'SATURDAY',
        startTime: saturdayFController.text,
        endTime: saturdayTController.text,
        availabilityType: IsAvailable(saturdayFController.text,saturdayTController.text),
      ),
    ];

    final Map<String, dynamic> requestBody = {
      'userId': userId,
      'availibilityDetails': availabilityDetailsList.map((detail) => detail.toJson()).toList(),
      'notes': 'my note',
      "clientId": clientId,
    };
    void _showSnackbar(String message,Color color) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),

        duration: const Duration(seconds: 2),
        backgroundColor: color,
      ));
    }
    final http.Response response = await http.post(
      Uri.parse('$apiPrefix/availability/create/'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
      body: jsonEncode(requestBody),
    );
    if (response.statusCode == 200) {
      // Successfully saved
      _showSnackbar('Availability saved successfully', Colors.green);
      Navigator.of(context).pop(); // Close the bottom sheet
    } else {
      // Handle error
      _showSnackbar('Failed to save availability. Status code: ${response.statusCode}', Colors.green);
    }
  }
  @override
  void initState() {
    super.initState();
    _fetchAvailability();
  }

  Future<void> _fetchAvailability() async {
    try {
      final http.Response response = await http.get(
        Uri.parse('$apiPrefix/availability'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> docs = responseBody['response']['docs'];
        setState(() {
          availabilityList = docs;
        });
      } else {
        print('Failed to fetch availability. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching availability: $error');
    }
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double listWidth = screenWidth < 600 ? screenWidth * 0.9 : 600;
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: listWidth,
            child: Column(

              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: availabilityList.map((availability) {
                    bool isApproved = availability['isApproved'];
                    return Card(
                      margin: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,

                      color: isApproved ? clrGreenWhite90 : Colors.red.shade50, // Change color based on approval status
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(1),
                          },
                          children: [
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    isApproved ? 'Approved' : 'Approval Pending',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(), // Empty cell to align with the start_time column
                                Container(), // Empty cell to align with the end_time column
                              ],
                            ),
                            for (int i = 0; i < availability['availibilityDetails'].length; i++)
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Text(
                                      '${availability['availibilityDetails'][i]['day_of_week']}',
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Text('${availability['availibilityDetails'][i]['start_time']}'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Text('${availability['availibilityDetails'][i]['end_time']}'),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAddAvailabilityPopup(context),child: const Icon(Icons.add)),
    );
  }

  Future<void> _showAddAvailabilityPopup(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TimePicker(
                        controller: sundayFController,
                        hintText: 'From',
                        labelText: 'Sunday from',
                      ),
                    ),
                    const Text('To'),
                    Expanded(
                      child: TimePicker(
                        controller: sundayTController,
                        hintText: 'To',
                        labelText: 'Sunday to',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TimePicker(
                        controller: mondayFController,
                        hintText: 'From',
                        labelText: 'Monday from',
                      ),
                    ),
                    const Text('To'),
                    Expanded(
                      child: TimePicker(
                        controller: mondayTController,
                        hintText: 'To',
                        labelText: 'Monday to',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TimePicker(
                        controller: tuesdayFController,
                        hintText: 'From',
                        labelText: 'Tuesday from',
                      ),
                    ),
                    const Text('To'),
                    Expanded(
                      child: TimePicker(
                        controller: tuesdayTController,
                        hintText: 'To',
                        labelText: 'Tuesday to',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TimePicker(
                        controller: wednesdayFController,
                        hintText: 'From',
                        labelText: 'Wednesday from',
                      ),
                    ),
                    const Text('To'),
                    Expanded(
                      child: TimePicker(
                        controller: wednesdayTController,
                        hintText: 'To',
                        labelText: 'Wednesday to',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TimePicker(
                        controller: thursdayFController,
                        hintText: 'From',
                        labelText: 'Thursday from',
                      ),
                    ),
                    const Text('To'),
                    Expanded(
                      child: TimePicker(
                        controller: thursdayTController,
                        hintText: 'To',
                        labelText: 'Thursday to',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TimePicker(
                        controller: fridayFController,
                        hintText: 'From',
                        labelText: 'Friday from',
                      ),
                    ),
                    const Text('To'),
                    Expanded(
                      child: TimePicker(
                        controller: fridayTController,
                        hintText: 'To',
                        labelText: 'Friday to',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TimePicker(
                        controller: saturdayFController,
                        hintText: 'From',
                        labelText: 'Saturday from',
                      ),
                    ),
                    const Text('To'),
                    Expanded(
                      child: TimePicker(
                        controller: saturdayTController,
                        hintText: 'To',
                        labelText: 'Saturday to',
                      ),
                    ),
                  ],
                ),

                // Add similar Rows for other days if needed
                const SizedBox(height: 16),
                RaisedButtonWidget(
                  buttonText: 'Save',
                  buttonTextColor: clrWhite,
                  bgColor: clrGreenOriginal,
                  onPressed: () {
                    _saveAvailability();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}