import 'dart:js_interop';

import 'package:extension/extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utilities/constants.dart';
import '../utilities/raised_button_widget.dart';
import '../utilities/text_form_field_widget.dart';
import 'user_home_screen.dart';

class LoginScreen extends StatefulWidget {

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _clientIdController = TextEditingController();
  bool isChecked = false;

  //show snakebar
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),

      duration: const Duration(seconds: 2),
      backgroundColor: Colors.red,
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(50.0),
      // ),
    ));
  }
  //validate if email, password and client id is empty or not
  bool _validateFields() {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _clientIdController.text.isEmpty) {
      _showSnackbar('All fields are required');
      return false;
    } else if (!_isValidEmail(_emailController.text)) {
      _showSnackbar('Invalid email format');
      return false;
    }
    if (isChecked) {
      _saveLoginCredentials();
    }
    return true;
  }
  void _saveLoginCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', _emailController.text);
    prefs.setString('password', _passwordController.text);
    prefs.setString('clientId', _clientIdController.text);
  }
  bool _isValidEmail(String email) {
    //  regular expression for email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> loginUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedEmail = prefs.getString('email') ?? '';
    String savedPassword = prefs.getString('password') ?? '';
    String savedClientId = prefs.getString('clientId') ?? '';

    _emailController.text = savedEmail;
    _passwordController.text = savedPassword;
    _clientIdController.text = savedClientId;

    final url = 'http://localhost:3000/users/login';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'loginWith': '0',
          'email': _emailController.text,
          'password': _passwordController.text,
          'clientId': _clientIdController.text,
        }),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['type'] == 'SUCCESS') {
        final String token = responseData['response']['token'];
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UserHomeScreen()),
        );
      } else {
        _showSnackbar(responseData['message']);
      }
    } catch (error) {
      _showSnackbar('Failed to load data');
    }
  }
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(

      backgroundColor: clrGreenOriginal,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(110.0),
                      bottomRight: Radius.circular(110.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        children: [
                          Hero(
                            tag: 'tagImage',
                            child: Center(
                              child: Image(
                                image: const AssetImage('images/shifttime.png'),
                                height: height * .2,
                                width: height * .5,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          const Center(
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
                          const SizedBox(
                            height: 10.0,
                          ),
                          const Center(
                            child: Text(
                              'Employee Shift Scheduling System',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: clrGreenOriginal,
                                fontFamily: fontFamily,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: clrGreenOriginal,
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
                          ),const SizedBox(
                            height: 10.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                            child: Center(
                              child: Container(
                                width: width * .6,
                                child: TextFormFieldWidget(
                                  keyboardType: TextInputType.number,
                                  validator: (String value) {
                                    if (value.isEmpty) {
                                      return 'Client Id is required';
                                    }
                                  },
                                  controller:_clientIdController,

                                  labelText: 'Client Id',
                                  hintText: 'enter your client id',
                                  icon: const Icon(
                                    Icons.lock_outlined,
                                    color: clrGreenOriginal,
                                  ), maxLength: 100,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                            child: Center(
                              child: Container(
                                width: width * .6,
                                child: TextFormFieldWidget(
                                  keyboardType: TextInputType.text,
                                  validator: (String value) {
                                    if (value.isEmpty) {
                                      return 'Email is required';
                                    }
                                  },


                                  controller: _emailController,
                                  labelText: 'Email',
                                  hintText: 'enter your email',
                                  icon: const Icon(
                                    Icons.person,
                                    color: clrGreenOriginal,
                                  ), maxLength:100,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                            child: Center(
                              child: Container(
                                width: width * .6,
                                child: TextFormFieldWidget(
                                  obSecureText: true,
                                  keyboardType: TextInputType.text,
                                  validator: (String value) {
                                    if (value.isEmpty) {
                                      return 'Password is required';
                                    }
                                  },
                                  controller: _passwordController,
                                  labelText: 'Password',
                                  hintText: 'enter your password',
                                  icon: const Icon(
                                    Icons.lock_outlined,
                                    color: clrGreenOriginal,
                                  ), maxLength: 100,
                                ),
                              ),
                            ),
                          ),

                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     Checkbox(
                          //       value: isChecked,
                          //       onChanged: (newValue) {
                          //         setState(() {
                          //           isChecked = newValue!;
                          //         });
                          //       },
                          //       activeColor: clrGreenOriginalLight,
                          //       checkColor: blueColor,
                          //     ),
                          //     const Text(
                          //       'Remember Me',
                          //       style: TextStyle(
                          //         color: Color(0xFF5E5F5E),
                          //         fontWeight: FontWeight.bold,
                          //         fontFamily: fontFamily,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RaisedButtonWidget(
                                buttonText: 'Log In',
                                onPressed: () async {
                                  if (_validateFields()) {
                                    loginUser();
                                  }
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
