import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'constants.dart';

class TimePicker extends StatefulWidget {
  TimePicker({super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
  });

  final String labelText, hintText;
  final TextEditingController controller;

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  TimeOfDay time = const TimeOfDay(hour: 12, minute: 00);

  onTapTimePicker({required BuildContext context}) async {
    TimeOfDay? selectedTime = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );
    if (selectedTime == null) return;
    String formattedTime = DateFormat.jm()
        .format(DateTime(2022, 1, 1, selectedTime.hour, selectedTime.minute));

    widget.controller.text = formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Center(
        child: TextFormField(
          onTap: () => onTapTimePicker(context: context),
          keyboardType: TextInputType.text,
          controller: widget.controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black12),
              borderRadius: BorderRadius.circular(50.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.0),
              borderSide: const BorderSide(color: Color(0xFF83C43E)),
            ),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
            labelText: widget.labelText,
            labelStyle: const TextStyle(
              color: Color(0xFF83C43E),
              fontFamily: fontFamily,
            ),
            hintText: widget.hintText,
            hintStyle: const TextStyle(
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
          cursorColor: const Color(0xFF83C43E),
        ),
      ),
    );
  }
}
