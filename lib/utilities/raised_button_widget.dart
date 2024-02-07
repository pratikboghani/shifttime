import 'package:flutter/material.dart';
import 'constants.dart';

class RaisedButtonWidget extends StatelessWidget {
  RaisedButtonWidget({
    required this.buttonText,
    required this.onPressed,
    required this.bgColor,
    required this.buttonTextColor,
  });

  final String buttonText;
  final Function onPressed;
  final Color bgColor, buttonTextColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed as void Function()?,
      child: Text(
        buttonText,
        style: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.bold,
          color: buttonTextColor,
        ),
      ),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        splashFactory: InkRipple.splashFactory,
      ),
    );
  }
}
