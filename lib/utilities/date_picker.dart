import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'constants.dart';

class DatePicker extends StatelessWidget {
  DatePicker(
      {required this.labelText,
        required this.hintText,
        required this.controller,
      });

  final String labelText, hintText;
  final TextEditingController controller;
  onTapFunction({required BuildContext context}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(1915),
      initialDate: DateTime.now(), lastDate: DateTime(5000),

    );
    onTapTimePicker({required BuildContext context}) async {
    }
    if (pickedDate == null) return;
    controller.text = DateFormat('dd-MM-yyyy').format(pickedDate);
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Center(
        child: Container(
          child: TextFormField(
            onTap: () => onTapFunction(context: context),
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
              contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
              labelText: labelText,
              labelStyle: TextStyle(
                color: Color(0xFF83C43E),
                fontFamily: fontFamily,
              ),
              hintText:  hintText,
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

