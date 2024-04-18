import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shifttime/utilities/setSession.dart';
import '../utilities/constants.dart';
import '../utilities/getSession.dart';
import '../utilities/raised_button_widget.dart';
import '../utilities/text_form_field_widget.dart';
import 'admin_home_screen.dart';
import 'user_home_screen.dart';
import 'package:intl/intl.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showLogin = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _clientIdController = TextEditingController();
  final TextEditingController _fclientIdController = TextEditingController();
  final TextEditingController _femailController = TextEditingController();
  final TextEditingController _fbirthDateController = TextEditingController();
  final TextEditingController _fpasswordController = TextEditingController();
  final TextEditingController _fpasswordConfController =
      TextEditingController();

  bool isChecked = true;

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

    return true;
  }

  bool _isValidEmail(String email) {
    //  regular expression for email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
  Future<void> saveSessionData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userToken', userToken);
    prefs.setString('userId', userId);
    prefs.setString('userRole', userRole);
    prefs.setString('clientId', clientId);
    prefs.setString('firstName', firstName);
    prefs.setString('defaultPassword', defaultPassword);
  }

  Future<void> loginUser() async {
    final url = '$apiPrefix/users/login';
    try {
      print(url);
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
print(responseData);
      if (responseData['type'] == 'SUCCESS') {
        print(responseData);
        userToken = responseData['response']['token'];
        userRole = responseData['response']['user']['role'];
        userId = responseData['response']['user']['_id'];
        clientId = responseData['response']['user']['clientId'].toString();
        firstName = responseData['response']['user']['firstName'];
        if(userRole == "ADMIN"){
          defaultPassword = responseData['response']['user']['defaultPassword'];
          await setSession('defaultPassword', defaultPassword);
        }
        await setSession('userToken', userToken);
        await setSession('userRole', userRole);
        await setSession('clientId', clientId);
        await setSession('firstName', firstName);
        String data = await loadSession('userToken');
        String userRoleData = await loadSession('userRole');
        saveSessionData();
        if (userRoleData == "EMPLOYEE") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserHomeScreen()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
          );
        }
      } else {
        _showSnackbar(responseData['message']);
      }
    } catch (error) {
      _showSnackbar('Failed to load data');
    }
  }

  onTapFunction({required BuildContext context}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      lastDate: DateTime.now(),
      firstDate: DateTime(2015),
      initialDate: DateTime.now(),
    );
    if (pickedDate == null) return;
    _fbirthDateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
  }

  Widget _buildLoginUI(double width, double height) {
    double containerWidth =
        MediaQuery.of(context).size.width < mobileScreenWidthThreshold
            ? width * 0.6
            : width * 0.4;
    return ListView(
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
          height: 30.0,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 50.0, right: 50.0),
          child: Center(
            child: Container(
              width: containerWidth,
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
                  Icons.email_outlined,
                  color: clrGreenOriginal,
                ),
                maxLength: 100,
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
              width: containerWidth,
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
                  Icons.password_outlined,
                  color: clrGreenOriginal,
                ),
                maxLength: 100,
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
              width: containerWidth,
              child: TextFormFieldWidget(
                keyboardType: TextInputType.number,
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'Client Id is required';
                  }
                },
                controller: _clientIdController,
                labelText: 'Client Id',
                hintText: 'enter your client id',
                icon: const Icon(
                  Icons.person,
                  color: clrGreenOriginal,
                ),
                maxLength: 100,
              ),
            ),
          ),
        ),
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
            // RaisedButtonWidget(
            //   buttonText: 'Log In admin',
            //   onPressed: () async {
            //     setState(() {
            //       clientId = '1001';
            //       firstName = 'Pratik';
            //     });
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) => const AdminHomeScreen()),
            //     );
            //   },
            //   bgColor: clrGreenOriginalLight,
            //   buttonTextColor: blueColor,
            // ),
            // RaisedButtonWidget(
            //   buttonText: 'Log In user',
            //   onPressed: () async {
            //     setState(() {
            //       clientId = '1001';
            //       firstName = 'Pratik';
            //       userId = '6605d586e0ee7c70cc9f6e6d';
            //     });
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) => const UserHomeScreen()),
            //     );
            //   },
            //   bgColor: clrGreenOriginalLight,
            //   buttonTextColor: blueColor,
            // ),
          ],
        ),
        const SizedBox(
          height: 20.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Forgot Password?'),
            TextButton(
              onPressed: () {
                setState(() {
                  showLogin = false;
                });
              },
              child: Text('Click Here!'),
            )
          ],
        )
      ],
    );
  }

  // Widget _buildForgotPasswordUI(double width, double height) {
  //   return ListView(
  //     shrinkWrap: true,
  //     physics: const BouncingScrollPhysics(),
  //     scrollDirection: Axis.vertical,
  //     children: [
  //       Hero(
  //         tag: 'tagImage',
  //         child: Center(
  //           child: Image(
  //             image: const AssetImage('images/shifttime.png'),
  //             height: height * .2,
  //             width: height * .5,
  //           ),
  //         ),
  //       ),
  //       const SizedBox(
  //         height: 10.0,
  //       ),
  //       const Center(
  //         child: Text(
  //           'Change Password',
  //           style: TextStyle(
  //             letterSpacing: 1.5,
  //             fontSize: 26.0,
  //             fontWeight: FontWeight.bold,
  //             color: Color(0xFF5E5F5E),
  //             fontFamily: fontFamily,
  //           ),
  //         ),
  //       ),
  //       const SizedBox(
  //         height: 10.0,
  //       ),
  //       const Center(
  //         child: Text(
  //           'Employee Shift Scheduling System',
  //           style: TextStyle(
  //             fontSize: 15.0,
  //             fontWeight: FontWeight.bold,
  //             color: clrGreenOriginal,
  //             fontFamily: fontFamily,
  //           ),
  //         ),
  //       ),
  //       const SizedBox(
  //         height: 30.0,
  //       ),
  //
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Padding(
  //             padding: const EdgeInsets.only(left: 50.0, right: 5),
  //             child: Center(
  //               child: Container(
  //                 width: ((width * .6) / 2) - 2.5,
  //                 child: TextFormFieldWidget(
  //                   keyboardType: TextInputType.number,
  //                   validator: (String value) {
  //                     if (value.isEmpty) {
  //                       return 'Client Id is required';
  //                     }
  //                   },
  //                   controller: _fclientIdController,
  //                   labelText: 'Client Id',
  //                   hintText: 'enter your client id',
  //                   icon: const Icon(
  //                     Icons.person,
  //                     color: clrGreenOriginal,
  //                   ),
  //                   maxLength: 100,
  //                 ),
  //               ),
  //             ),
  //           ),
  //           Column(
  //             children: [
  //               Padding(
  //                 padding: const EdgeInsets.only(left: 5, right: 50.0),
  //                 child: Center(
  //                   child: Container(
  //                     width: ((width * .6) / 2) - 2.5,
  //                     child: TextFormField(
  //                       onTap: () => onTapFunction(context: context),
  //                       keyboardType: TextInputType.text,
  //                       controller: _fbirthDateController,
  //                       decoration: InputDecoration(
  //                         border: OutlineInputBorder(
  //                           borderSide: BorderSide(color: Colors.black12),
  //                           borderRadius: BorderRadius.circular(50.0),
  //                         ),
  //                         focusedBorder: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(50.0),
  //                           borderSide: BorderSide(color: Color(0xFF83C43E)),
  //                         ),
  //                         isDense: true,
  //                         contentPadding: EdgeInsets.symmetric(
  //                             vertical: 5.0, horizontal: 20.0),
  //                         labelText: 'Birth Date',
  //                         labelStyle: TextStyle(
  //                           color: Color(0xFF83C43E),
  //                           fontFamily: fontFamily,
  //                         ),
  //                         hintText: 'enter your Birth Date',
  //                         hintStyle: TextStyle(
  //                           color: Colors.grey,
  //                           fontSize: 12.0,
  //                           fontFamily: fontFamily,
  //                         ),
  //                         filled: true,
  //                         fillColor: Colors.white,
  //                         prefixIcon: const Icon(
  //                           Icons.date_range,
  //                           color: clrGreenOriginal,
  //                         ),
  //                       ),
  //                       cursorColor: Color(0xFF83C43E),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(
  //                 height: 20.0,
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //       const SizedBox(
  //         height: 10.0,
  //       ),
  //       Padding(
  //         padding: const EdgeInsets.only(left: 50.0, right: 50.0),
  //         child: Center(
  //           child: Container(
  //             width: width * .6,
  //             child: TextFormFieldWidget(
  //               keyboardType: TextInputType.text,
  //               validator: (String value) {
  //                 if (value.isEmpty) {
  //                   return 'Email is required';
  //                 }
  //               },
  //               controller: _femailController,
  //               labelText: 'Email',
  //               hintText: 'enter your email',
  //               icon: const Icon(
  //                 Icons.email_outlined,
  //                 color: clrGreenOriginal,
  //               ),
  //               maxLength: 100,
  //             ),
  //           ),
  //         ),
  //       ),
  //       const SizedBox(
  //         height: 10.0,
  //       ),
  //
  //       Padding(
  //         padding: const EdgeInsets.only(left: 50.0, right: 50.0),
  //         child: Center(
  //           child: Container(
  //             width: width * .6,
  //             child: TextFormFieldWidget(
  //               obSecureText: true,
  //               keyboardType: TextInputType.text,
  //               validator: (String value) {
  //                 if (value.isEmpty) {
  //                   return 'New password is required';
  //                 }
  //               },
  //               controller: _fpasswordController,
  //               labelText: 'New Password',
  //               hintText: 'enter new password',
  //               icon: const Icon(
  //                 Icons.password_outlined,
  //                 color: clrGreenOriginal,
  //               ),
  //               maxLength: 100,
  //             ),
  //           ),
  //         ),
  //       ),
  //       const SizedBox(
  //         height: 10.0,
  //       ),
  //       Padding(
  //         padding: const EdgeInsets.only(left: 50.0, right: 50.0),
  //         child: Center(
  //           child: Container(
  //             width: width * .6,
  //             child: TextFormFieldWidget(
  //               obSecureText: true,
  //               keyboardType: TextInputType.text,
  //               validator: (String value) {
  //                 if (value.isEmpty) {
  //                   return 'Confirm Password is required';
  //                 }
  //               },
  //               controller: _fpasswordConfController,
  //               labelText: 'Confirm Password',
  //               hintText: 'confirm your password',
  //               icon: const Icon(
  //                 Icons.password_outlined,
  //                 color: clrGreenOriginal,
  //               ),
  //               maxLength: 100,
  //             ),
  //           ),
  //         ),
  //       ),
  //       // Row(
  //       //   mainAxisAlignment: MainAxisAlignment.center,
  //       //   children: [
  //       //     Checkbox(
  //       //       value: isChecked,
  //       //       onChanged: (newValue) {
  //       //         setState(() {
  //       //           isChecked = newValue!;
  //       //         });
  //       //       },
  //       //       activeColor: clrGreenOriginalLight,
  //       //       checkColor: blueColor,
  //       //     ),
  //       //     const Text(
  //       //       'Remember Me',
  //       //       style: TextStyle(
  //       //         color: Color(0xFF5E5F5E),
  //       //         fontWeight: FontWeight.bold,
  //       //         fontFamily: fontFamily,
  //       //       ),
  //       //     ),
  //       //   ],
  //       // ),
  //       const SizedBox(
  //         height: 20.0,
  //       ),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           RaisedButtonWidget(
  //             buttonText: 'Update Log In',
  //             onPressed: () async {
  //               if (_validateFields()) {
  //                 loginUser();
  //               }
  //             },
  //             bgColor: clrGreenOriginalLight,
  //             buttonTextColor: blueColor,
  //           ),
  //         ],
  //       ),
  //       const SizedBox(
  //         height: 20.0,
  //       ),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           const Text('Cancel Forgot Password?'),
  //           TextButton(
  //             onPressed: () {
  //               setState(() {
  //                 showLogin = true;
  //               });
  //             },
  //             child: const Text('Login Here!'),
  //           )
  //         ],
  //       )
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    var radious = width < 600 ? width * .5 : width * .1;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: clrGreenOriginal,
      ),
      backgroundColor: clrGreenOriginal,
      body: SingleChildScrollView(
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
                    topRight: Radius.circular(150),
                    bottomRight: Radius.circular(0.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Container(
                    child: Form(
                      key: _formKey,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: showLogin
                            ? _buildLoginUI(width, height)
                            : _buildForgotPasswordUI(width, height),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
