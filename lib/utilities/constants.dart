import 'dart:convert';
import 'dart:js';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

// var scrWidth = MediaQuery.of(context as BuildContext).size.width;
// var scrHeight = MediaQuery.of(context as BuildContext).size.height;

const clrGreenOriginal = Color(0xff43a756);
const clrGreenOriginalLight = Color(0xFFd9eddd);
const clrGreenWhite10 = Color(0xFF56b067);
const clrGreenWhite20 = Color(0xFF69b978);
const clrGreenWhite30 = Color(0xFF7bc189);
const clrGreenWhite40 = Color(0xFF8eca9a);
const clrGreenWhite50 = Color(0xFFa1d3ab);
const clrGreenWhite60 = Color(0xFFb4dcbb);
const clrGreenWhite70 = Color(0xFFc7e5cc);
const clrGreenWhite80 = Color(0xFFd9eddd);
const clrGreenWhite90 = Color(0xFFecf6ee);
const clrGreenDark10 = Color(0xFF3c964d);
const clrGreenDark20 = Color(0xFF368645);
const clrGreenDark30 = Color(0xFF2f753c);
const clrGreenDark40 = Color(0xFF286434);
const clrGreenDark50 = Color(0xFF22542b);
const clrGreenDark60 = Color(0xFF1b4322);
const clrGreenDark70 = Color(0xFF14321a);
const clrGreenDark80 = Color(0xFF0d2111);
const clrGreenDark90 = Color(0xFF071109);
const clrBlack = Colors.black;
const clrWhite = Colors.white;
const blueColor = Color(0xFF1B5A77);
const greyColor = Colors.black;
//Color(0xFF5E5F5E);
const apiPrefix = 'https://shifttime.onrender.com';
// const apiPrefix = 'http://103.155.115.118:8686/';
// const apiPrefix = 'http://localhost:3000';

const welcomeTextStyle = TextStyle(
  fontSize: 23,
  color: Colors.black,
  fontWeight: FontWeight.w500,
  fontFamily: fontFamily,
);

const welcomeTextWidget = Text(
  'Welcome,',
  style: welcomeTextStyle,
);

const fontFamily = 'Rubik';

final ThemeData mytheme = ThemeData(
  // Colors
  primaryColor: clrGreenOriginal,
  hintColor: clrGreenDark50,
  scaffoldBackgroundColor: clrWhite,
  // Customize the error color here

  // Typography
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: clrGreenOriginal),
    bodyMedium: TextStyle(color: clrGreenDark50),
    titleLarge: TextStyle(color: clrGreenOriginal, fontWeight: FontWeight.bold),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: clrGreenOriginal,
    foregroundColor: clrWhite,
    titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: clrGreenOriginal,
    foregroundColor: Colors.white,
    focusColor: clrGreenDark40,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
    ),
  ),
  // Buttons
  buttonTheme: const ButtonThemeData(
    buttonColor: clrGreenOriginal,
    textTheme: ButtonTextTheme.primary,
  ),

  // Input decoration
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.black12),
      borderRadius: BorderRadius.circular(50.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50.0),
      borderSide: const BorderSide(color: Color(0xFF83C43E)),
    ),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
    labelStyle: const TextStyle(
      color: Color(0xFF83C43E),
      fontFamily: fontFamily,
    ),
    hintStyle: const TextStyle(
      color: Colors.grey,
      fontSize: 12.0,
      fontFamily: fontFamily,
    ),
    filled: true,
    fillColor: Colors.white,
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: MaterialStateColor.resolveWith(
      (states) => clrGreenWhite50,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: clrGreenOriginal,
    ),
  ),


  datePickerTheme: DatePickerThemeData(
    backgroundColor: clrWhite,
    headerHelpStyle: const TextStyle(color: clrBlack, fontSize: 18.0),
    shadowColor: clrGreenWhite40,
    dayStyle: const TextStyle(color: clrGreenOriginal),
    dayBackgroundColor: MaterialStateColor.resolveWith(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return clrGreenOriginal;
        } else if (states.contains(MaterialState.hovered)) {
          return clrGreenOriginal.withOpacity(0.9);
        } else {
          return clrGreenWhite90;
        }
      },
    ),
    weekdayStyle: const TextStyle(color: clrBlack, fontWeight: FontWeight.bold),
    yearBackgroundColor: MaterialStateColor.resolveWith(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return clrGreenOriginal;
        } else if (states.contains(MaterialState.hovered)) {
          return clrGreenOriginal.withOpacity(0.9);
        } else {
          return clrGreenWhite90;
        }
      },
    ),
    todayBackgroundColor: MaterialStateColor.resolveWith(
          (Set<MaterialState> states) {
          return clrGreenWhite30;
      },
    ),
    rangePickerBackgroundColor: clrGreenOriginal,
    inputDecorationTheme: const InputDecorationTheme(fillColor: clrGreenWhite90),
      headerBackgroundColor: clrGreenWhite70,
    surfaceTintColor: clrGreenWhite40,
  ),


  timePickerTheme: const TimePickerThemeData(
    backgroundColor: clrWhite,
    helpTextStyle: TextStyle(color: clrBlack),
    hourMinuteColor: clrGreenWhite40,
    dayPeriodTextStyle: TextStyle(color: clrWhite),
    dialHandColor: clrGreenWhite40,
    dialTextColor: clrBlack,
    entryModeIconColor: clrGreenOriginal,
    hourMinuteTextStyle: TextStyle(color: clrWhite),
  ),
  // Dialogs
  dialogTheme: DialogTheme(
    backgroundColor: clrWhite,
    titleTextStyle:
        const TextStyle(color: clrGreenOriginal, fontWeight: FontWeight.bold),
    contentTextStyle: const TextStyle(color: clrGreenDark50),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),

  // Snackbars
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Colors.red,
    contentTextStyle: TextStyle(color: clrWhite),
  ),

  // Card
  cardTheme: CardTheme(
    color: clrGreenWhite90,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  //tabbar
  tabBarTheme: const TabBarTheme(
    labelColor: clrGreenOriginal,
    unselectedLabelColor: clrGreenDark60,
    labelStyle: TextStyle(
      fontWeight: FontWeight.bold,
    ),
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(width: 4, color: clrGreenOriginal),
    ),
  ),
  // Bottom Navigation Bar
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: clrGreenOriginal,
    selectedItemColor: clrWhite,
    unselectedItemColor: clrGreenDark50,
  ),

  listTileTheme: const ListTileThemeData(
      textColor: clrBlack, selectedColor: clrGreenOriginal),
  // Divider
  dividerTheme: const DividerThemeData(
    color: clrGreenDark30,
    space: 16,
    thickness: 1,
  ),

  // Toggle Buttons
  toggleButtonsTheme: ToggleButtonsThemeData(
    color: clrGreenDark50,
    selectedColor: clrGreenOriginal,
    fillColor: clrGreenWhite10,
    borderRadius: BorderRadius.circular(8),
    borderWidth: 1,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.hovered)) {
            return clrGreenWhite90; // Hover color
          }
          return clrWhite; // Default color
        },
      ),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(8.0), // Border radius for the button
        ),
      ),
    ),
  ),
);

Future<Map<String, dynamic>> fetchData(String apiUrl) async {
  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load data');
  }
}

// session variables
var userToken;
var userRole;
var clientId;
var userId;
var firstName;
const double mobileScreenWidthThreshold = 400.0;
var defaultPassword='ShiftTime';
double? spaceBtwnTwoField=15;
