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
  bool _mondayChecked = true;
  bool _tuesdayChecked = true;
  bool _wednesdayChecked = true;
  bool _thursdayChecked = true;
  bool _fridayChecked = true;
  bool _saturdayChecked = true;
  bool _sundayChecked = true;
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
          SizedBox(width: double.infinity,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButtonWidget(
              bgColor: clrGreenOriginal,
              buttonText: 'Add Availability',
              buttonTextColor: clrWhite,
              onPressed: () => _showAddAvailabilityPopup(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddAvailabilityPopup(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  _buildDayCheckbox('Sunday', _sundayChecked),
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
              // Add similar Rows for other days if needed
              SizedBox(height: 16),
              RaisedButtonWidget(
                buttonText: 'Save',
                buttonTextColor: clrWhite,
                bgColor: clrGreenOriginal,
                onPressed: () {
                  // Handle the button press in the popup
                  // For example, you can save the selected availability
                  // and then close the popup
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayCheckbox(String day, bool checked) {
    return Row(
      children: [
        Checkbox(
          value: checked,
          onChanged: (newValue) {
            setState(() {
              if (day == 'Sunday') {
                _sundayChecked = newValue!;
              }
            });
          },
        ),
        Text(day),
      ],
    );
  }
}
