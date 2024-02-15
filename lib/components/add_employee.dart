import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import '../utilities/constants.dart';
import '../utilities/text_form_field_widget.dart';

class AddEmployeeForm extends StatefulWidget {
  const AddEmployeeForm({Key? key}) : super(key: key);

  @override
  _InsertUserFormState createState() => _InsertUserFormState();
}

class _InsertUserFormState extends State<AddEmployeeForm> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController roleController = TextEditingController(text: 'EMPLOYEE');
  final TextEditingController genderController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emergencyContactNameController =
  TextEditingController();
  final TextEditingController emergencyContactNumberController =
  TextEditingController();
  String selectedValue = "USA";
  final TextEditingController clientIdController = TextEditingController(text: '1001');

  Future<void> insertUser() async {
    if (_validateFields()) {
      final url = '$apiPrefix/users/signup/';

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'loginWith': 0,
            'firstName': firstNameController.text,
            'lastName': lastNameController.text,
            'email': emailController.text,
            'role': roleController.text,
            'gender': genderController.text,
            'birthdate': birthdateController.text,
            'mobile': mobileController.text,
            'clientId': clientIdController.text,
            'emergencyContactName': emergencyContactNameController.text,
            'emergencyContactNumber':emergencyContactNumberController.text,
            'password': 'pppppppp'
          }),
        );

        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['type'] == 'SUCCESS') {
          print('User inserted successfully');
          _showSuccessSnackbar();
        } else {
          print('Failed to insert user: ${responseData['message']}');
          _showErrorSnackbar('Failed to insert user: ${responseData['message']}');
        }
      } catch (error) {
        print('Failed to insert user: $error');
        _showErrorSnackbar('Failed to insert user: $error');
      }
    }
  }

  bool _validateFields() {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        genderController.text.isEmpty ||
        birthdateController.text.isEmpty ||
        mobileController.text.isEmpty ||
        emergencyContactNameController.text.isEmpty ||
        emergencyContactNumberController.text.isEmpty ||
        clientIdController.text.isEmpty) {
      _showErrorSnackbar('All fields are required');
      return false;
    }
    return true;
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('User added successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
        onVisible: () {
          // Clear the fields after the Snackbar is visible
          firstNameController.clear();
          lastNameController.clear();
          emailController.clear();
          genderController.clear();
          birthdateController.clear();
          mobileController.clear();
          emergencyContactNameController.clear();
          emergencyContactNumberController.clear();
          // clientIdController.clear();
        },
      ),
    );
  }

  void _showErrorSnackbar(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
  onTapFunction({required BuildContext context}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      lastDate: DateTime.now(),
      firstDate: DateTime(1915),
      initialDate: DateTime.now(),

    );
    if (pickedDate == null) return;
    birthdateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormFieldWidget(
                obSecureText: false,
                keyboardType: TextInputType.text,
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'First name is required';
                  }
                },
                controller: firstNameController,
                labelText: 'First Name',
                hintText: 'enter your first name',
                icon: const Icon(
                  Icons.person,
                  color: clrGreenOriginal,
                ), maxLength: 100,
              ),
              TextFormFieldWidget(
                obSecureText: false,
                keyboardType: TextInputType.text,
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'Last name is required';
                  }
                },
                controller: lastNameController,
                labelText: 'Last Name',
                hintText: 'enter your last name',
                icon: const Icon(
                  Icons.person,
                  color: clrGreenOriginal,
                ), maxLength: 100,
              ),
              TextFormFieldWidget(
                obSecureText: false,
                keyboardType: TextInputType.text,
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'Email is required';
                  }
                },
                controller: emailController,
                labelText: 'Email',
                hintText: 'enter your email',
                icon: const Icon(
                  Icons.email_outlined,
                  color: clrGreenOriginal,
                ), maxLength: 100,
              ),
              TextFormFieldWidget(
                obSecureText: false,
                keyboardType: TextInputType.text,
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'Gender is required';
                  }
                },
                controller: genderController,
                labelText: 'Gender',
                hintText: 'enter your gender',
                icon: const Icon(
                  Icons.male_outlined,
                  color: clrGreenOriginal,
                ), maxLength: 100,
              ),
              // DropdownButton(
              //     value: selectedValue,
              //     items: dropdownItems, onChanged: (String? value) {  },
              // ),
              Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: Center(
                  child: Container(
          
                    child: TextFormField(
                      onTap: () => onTapFunction(context: context),
                      keyboardType: TextInputType.text,
                      controller: birthdateController,
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
                        labelText: 'Birth Date',
                        labelStyle: TextStyle(
                          color: Color(0xFF83C43E),
                          fontFamily: fontFamily,
                        ),
                        hintText:  'enter your Birth Date',
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
              ),
              TextFormFieldWidget(
                obSecureText: false,
                keyboardType: TextInputType.text,
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'Mobile number is required';
                  }
                },
                controller: mobileController,
                labelText: 'Mobile Number',
                hintText: 'enter your mobile number',
                icon: const Icon(
                  Icons.phone,
                  color: clrGreenOriginal,
                ), maxLength: 100,
              ),
              TextFormFieldWidget(
                obSecureText: false,
                keyboardType: TextInputType.text,
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'Emergency contact is required';
                  }
                },
                controller: emergencyContactNameController,
                labelText: 'Emergency contact Name',
                hintText: 'enter emergency contact name',
                icon: const Icon(
                  Icons.contact_emergency_outlined,
                  color: clrGreenOriginal,
                ), maxLength: 100,
              ),
              TextFormFieldWidget(
                obSecureText: false,
                keyboardType: TextInputType.text,
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'Emergency contact name is required';
                  }
                },
                controller: emergencyContactNumberController,
                labelText: 'Emergency contact number',
                hintText: 'enter emergency contact number',
                icon: const Icon(
                  Icons.contact_emergency_rounded,
                  color: clrGreenOriginal,
                ), maxLength: 100,
              ),
              TextFormFieldWidget(
                obSecureText: false,
                keyboardType: TextInputType.text,
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'Username is required';
                  }
                },
                controller: userNameController,
                labelText: 'Username',
                hintText: 'enter username',
                icon: const Icon(
                  Icons.person,
                  color: clrGreenOriginal,
                ), maxLength: 100,
              ),
          
          
              // Add more TextFields for additional fields
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  insertUser();
                },
                child: Text('Insert User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
