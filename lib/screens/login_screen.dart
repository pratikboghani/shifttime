import 'package:extension/extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utilities/constants.dart';
import '../utilities/raised_button_widget.dart';
import '../utilities/text_form_field_widget.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String userId, password;
  bool isChecked = false;


  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: clrGeenOriginal,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 10.0,
                  right: 10.0,
                  bottom: 10.0,
                ),
                child: Container(
                  height: height * 0.88,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(110.0),
                      bottomRight: Radius.circular(110.0),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 40.0),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        children: [
                          Hero(
                            tag: 'tagImage',
                            child: Center(
                              child: Image(
                                image: AssetImage('images/shifttime.png'),
                                height: height * .2,
                                width: height * .5,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Center(
                            child: Text(
                              'Login',
                              style: TextStyle(
                                letterSpacing: 1.5,
                                fontSize: 26.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5E5F5E),
                                fontFamily: fontFamily,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Center(
                            child: Text(
                              'Employee Shift Scheduling System',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: clrGeenOriginal,
                                fontFamily: fontFamily,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: clrGeenOriginal,
                                  fontFamily: fontFamily,
                                ),
                              ),
                              SizedBox(
                                width: 8.0,
                              ),
                              Text(
                                '',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5E5E5E),
                                  fontFamily: fontFamily,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 50.0, right: 50.0),
                            child: Center(
                              child: Container(
                                width: width * .6,
                                child: TextFormFieldWidget(
                                  keyboardType: TextInputType.text,
                                  validator: (String value) {
                                    if (value.isEmpty) {
                                      return 'userId is required';
                                    }
                                  },
                                  onSaved: (String value) {
                                    userId = value.capitalizeFirstLetter();
                                  },
                                  labelText: 'userId',
                                  hintText: 'enter your userId',
                                  icon: Icon(
                                    Icons.person,
                                    color: clrGeenOriginal,
                                  ), maxLength:100,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 50.0, right: 50.0),
                            child: Center(
                              child: Container(
                                width: width * .6,
                                child: TextFormFieldWidget(
                                  obSecureText: true,
                                  keyboardType: TextInputType.text,
                                  validator: (String value) {
                                    if (value.isEmpty) {
                                      return 'password is required';
                                    }
                                  },
                                  onSaved: (value) {
                                    password = value;
                                  },
                                  labelText: 'password',
                                  hintText: 'enter your password',
                                  icon: Icon(
                                    Icons.lock_outlined,
                                    color: clrGeenOriginal,
                                  ), maxLength: 100,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: isChecked,
                                onChanged: (newValue) {
                                  setState(() {
                                    // isChecked = newValue;
                                    print(isChecked);
                                  });
                                },
                                activeColor: clrGreenOriginalLight,
                                checkColor: blueColor,
                              ),
                              Text(
                                'Remember Me                               ',
                                style: TextStyle(
                                  color: Color(0xFF5E5F5E),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: fontFamily,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RaisedButtonWidget(
                                buttonText: 'Log In',
                                onPressed: () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => HomeScreen()),
                                  );
                                  // if (_formKey.currentState != null) {
                                  //   if (!_formKey.currentState.validate()) {
                                  //     return;
                                  //   }
                                  //   _formKey.currentState.save();
                                  //   FocusScopeNode currentFocus =
                                  //   FocusScope.of(context);
                                  //   if (!currentFocus.hasPrimaryFocus) {
                                  //     currentFocus.unfocus();
                                  //   }
                                  // }
                                  // if (isChecked == true) {
                                  //   SharedPreferences prefs =
                                  //   await SharedPreferences.getInstance();
                                  //   prefs.setString('userId', userId);
                                  //   prefs.setString('password', password);
                                  // }
                                  // Navigator.push(
                                  //     context,
                                  //     PageTransition(
                                  //         child:
                                  //         TotalTaskScreen(userId: userId),
                                  //         type: PageTransitionType.scale,
                                  //         alignment: Alignment.topCenter));
                                },
                                bgColor: clrGreenOriginalLight,
                                buttonTextColor: blueColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
