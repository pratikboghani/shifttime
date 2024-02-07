import 'package:flutter/material.dart';

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
const apiPrefix = 'http://103.155.115.118:8686/';

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

final ThemeData mytheme= ThemeData(
    // Colors
    primaryColor: clrGreenOriginal,
    hintColor: clrGreenDark50,
    scaffoldBackgroundColor: clrWhite, // Customize the error color here

    // Typography
    textTheme: const TextTheme(
    bodyLarge: TextStyle(color: clrGreenOriginal),
    bodyMedium: TextStyle(color: clrGreenDark50),
    titleLarge: TextStyle(color: clrGreenOriginal, fontWeight: FontWeight.bold),

    // Customize more text styles as needed
    ),
    appBarTheme: const AppBarTheme(
    backgroundColor: clrGreenOriginal,
    foregroundColor: clrWhite,
    titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),

    // Buttons
    buttonTheme: const ButtonThemeData(
    buttonColor: clrGreenOriginal,
    textTheme: ButtonTextTheme.primary,
    ),

    // Input decoration
    inputDecorationTheme: const InputDecorationTheme(
    fillColor: clrGreenWhite10,
    filled: true,
    focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: clrGreenOriginal),
    ),
    enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: clrGreenOriginalLight),
    ),
    errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red),
    ),
    // Customize more input decoration properties as needed
    ),

    // Dialogs
    dialogTheme: DialogTheme(
    backgroundColor: clrWhite,
    titleTextStyle: const TextStyle(color: clrGreenOriginal, fontWeight: FontWeight.bold),
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

    // Bottom Navigation Bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: clrGreenOriginal,
    selectedItemColor: clrWhite,
    unselectedItemColor: clrGreenDark50,
    ),

    listTileTheme: const ListTileThemeData(textColor: clrBlack, selectedColor: clrGreenOriginal),
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
          borderRadius: BorderRadius.circular(8.0), // Border radius for the button
        ),
      ),
    ),
  ),


);