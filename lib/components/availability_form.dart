import 'package:flutter/material.dart';
import 'package:shifttime/utilities/constants.dart';
import 'package:shifttime/utilities/date_picker.dart';
import 'package:shifttime/utilities/raised_button_widget.dart';
import 'package:shifttime/utilities/time_picker.dart';

class AvailabilityForm extends StatefulWidget {
  @override
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: RaisedButtonWidget(
          //     bgColor: clrGreenOriginal,
          //     buttonText: 'Add Availability',
          //     buttonTextColor: clrWhite,
          //     onPressed: () => _showAddAvailabilityPopup(context),
          //   ),
          // ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAddAvailabilityPopup(context),child: Icon(Icons.add)),
    );
  }

  Future<void> _showAddAvailabilityPopup(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
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
                    Text('To'),
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
                    Text('To'),
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
                    Text('To'),
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
                    Text('To'),
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
                    Text('To'),
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
                    Text('To'),
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
                    Text('To'),
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
                SizedBox(height: 16),
                RaisedButtonWidget(
                  buttonText: 'Save',
                  buttonTextColor: clrWhite,
                  bgColor: clrGreenOriginal,
                  onPressed: () {



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

