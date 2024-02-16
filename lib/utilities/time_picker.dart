import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'constants.dart';

class TimePicker extends StatelessWidget {
  TimePicker({
    required this.labelText,
    required this.hintText,
    required this.controller,
  });

  final String labelText, hintText;
  final TextEditingController controller;
  TimeOfDay time = TimeOfDay(hour: 12, minute: 00);

  onTapTimePicker({required BuildContext context}) async {
    TimeOfDay? selectedTime = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );
    if (selectedTime == null) return;
    String formattedTime = DateFormat.jm()
        .format(DateTime(2022, 1, 1, selectedTime.hour, selectedTime.minute));

    controller.text = formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Center(
        child: Container(
          child: TextFormField(
            onTap: () => onTapTimePicker(context: context),
            keyboardType: TextInputType.text,
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black12),
                borderRadius: BorderRadius.circular(50.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50.0),
                borderSide: BorderSide(color: Color(0xFF83C43E)),
              ),
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
              labelText: labelText,
              labelStyle: TextStyle(
                color: Color(0xFF83C43E),
                fontFamily: fontFamily,
              ),
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: 12.0,
                fontFamily: fontFamily,
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(
                Icons.date_range,
                color: clrGreenOriginal,
              ),
            ),
            cursorColor: Color(0xFF83C43E),
          ),
        ),
      ),
    );
  }
}
