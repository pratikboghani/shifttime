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
  final TextEditingController roleController =
      TextEditingController(text: 'EMPLOYEE');
  final TextEditingController genderController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();

  // final TextEditingController categoryController = TextEditingController();

  final TextEditingController emergencyContactNameController =
      TextEditingController();
  final TextEditingController emergencyContactNumberController =
      TextEditingController();
  String selectedValue = "USA";
  final TextEditingController clientIdController =
      TextEditingController(text: '1001');
  List<String> categories = [];
  List<String> categoriesId = [];
  String selectedCategory = '';
  String selectedCategoryId = '';

  Future<void> insertUser() async {
    if (_validateFields()) {
      const url = '$apiPrefix/users/signup/';

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
            'emergencyContactNumber': emergencyContactNumberController.text,
            'userName': userNameController.text,
            'password': defaultPassword,
            'category': selectedCategory,
            'workRole': selectedCategoryId
          }),
        );

        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['type'] == 'SUCCESS') {
          _showSuccessSnackbar();
        } else {
          _showErrorSnackbar(
              'Failed to insert user: ${responseData['message']}');
        }
      } catch (error) {
        _showErrorSnackbar('Failed to insert user: $error');
      }
    }
  }

  bool _validateFields() {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        roleController.text.isEmpty ||
        genderController.text.isEmpty ||
        birthdateController.text.isEmpty ||
        mobileController.text.isEmpty ||
        emergencyContactNameController.text.isEmpty ||
        emergencyContactNumberController.text.isEmpty ||
        clientIdController.text.isEmpty ||
        userNameController.text.isEmpty ||
        selectedCategory.length == 0) {
      _showErrorSnackbar('All fields are required');
      return false;
    }
    return true;
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('User added successfully!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
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
          userNameController.clear();
          selectedCategory = '';
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
        duration: const Duration(seconds: 3),
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
    birthdateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
  }

  Future<void> _fetchCategories() async {
    String apiUrl = '$apiPrefix/category?query={"clientId": $clientId}';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> docs = responseData['response']['docs'];

        setState(() {
          categories = docs
              .map<String>((category) => category['category'].toString())
              .toList();
          categoriesId = docs
              .map<String>((category) => category['_id'].toString())
              .toList();
          // if (categories.isNotEmpty) {
          //   selectedCategory = categories[0];
          // }
        });
        print(categories);
      } else {
        // Handle error response
        print(
            'Failed to fetch categories. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      // Handle network error
      print('Error fetching categories: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth < 600 ? screenWidth * 0.8 : 400;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              width: containerWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('*Default Password is $defaultPassword'),
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
                    ),
                    maxLength: 100,
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
                    ),
                    maxLength: 100,
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
                    ),
                    maxLength: 100,
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
                    ),
                    maxLength: 100,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: Center(
                      child: TextFormField(
                        onTap: () => onTapFunction(context: context),
                        keyboardType: TextInputType.text,
                        controller: birthdateController,
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
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 20.0),
                          labelText: 'Birth Date',
                          labelStyle: const TextStyle(
                            color: Color(0xFF83C43E),
                            fontFamily: fontFamily,
                          ),
                          hintText: 'enter your Birth Date',
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
                    ),
                    maxLength: 100,
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
                    ),
                    maxLength: 100,
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
                    ),
                    maxLength: 100,
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
                    ),
                    maxLength: 100,
                  ),
                  DropdownButtonFormField<String>(
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedCategory = newValue;
                          selectedCategoryId =
                              categoriesId[categories.indexOf(newValue)];
                        });
                      }
                    },
                    items: categories.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      hintText: 'Select category',
                      labelText: 'Category',
                      prefixIcon: Icon(
                        Icons.category,
                        color: clrGreenOriginal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith(
                          (Set<MaterialState> states) {
                        return clrGreenWhite60;
                      }),
                      foregroundColor: MaterialStateColor.resolveWith(
                        (Set<MaterialState> states) {
                          return clrBlack;
                        },
                      ),
                    ),
                    onPressed: () {
                      insertUser();
                    },
                    child: const Text('Insert User'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
