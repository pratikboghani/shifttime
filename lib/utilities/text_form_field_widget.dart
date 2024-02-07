import 'package:flutter/material.dart';

import 'constants.dart';

class TextFormFieldWidget extends StatelessWidget {
  TextFormFieldWidget(
      {
      required this.labelText,
        required this.hintText,
        required this.icon,
        required this.keyboardType,
        required this.validator,
        required this.controller,
        this.obSecureText = false, required this.maxLength});

  final int maxLength;
  final String labelText, hintText;
  final Icon icon;
  final TextInputType keyboardType;
  final Function validator;
  final bool obSecureText;
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obSecureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: 1,
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
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
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
        prefixIcon: icon,
      ),
      cursorColor: Color(0xFF83C43E),
    );
  }
}
