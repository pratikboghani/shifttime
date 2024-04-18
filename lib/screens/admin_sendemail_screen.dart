import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utilities/constants.dart';
import '../utilities/text_form_field_widget.dart';

class SendEmail extends StatefulWidget {
  const SendEmail({Key? key}) : super(key: key);

  @override
  State<SendEmail> createState() => _SendEmailState();
}

class _SendEmailState extends State<SendEmail> {
  final TextEditingController descriptionController = TextEditingController();
  late List<Employee> employees;
  late Map<String, List<Employee>> categorizedEmployees;
  Set<String> selectedEmails = Set<String>();
  Set<String> selectedCategories = Set<String>();
  bool selectAll = false;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
    employees = [];
    categorizedEmployees = {};
  }

  void _showSnackbar(String errorMessage, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _fetchEmployees() async {
    final apiUrl = '$apiPrefix/users?query={"clientId": $clientId}';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> docs = responseData['response']['docs'];

      setState(() {
        employees = docs.map((json) => Employee.fromJson(json)).toList();
        _categorizeEmployees();
      });
    } else {
      // Handle error response
      print('Failed to fetch employees. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void _categorizeEmployees() {
    categorizedEmployees.clear();
    for (var employee in employees) {
      if (!categorizedEmployees.containsKey(employee.category)) {
        categorizedEmployees[employee.category ?? ""] = [];
      }
      categorizedEmployees[employee.category ?? ""]?.add(employee);
    }
  }

  void _toggleSelection(String email) {
    setState(() {
      if (selectedEmails.contains(email)) {
        selectedEmails.remove(email);
      } else {
        selectedEmails.add(email);
      }
      // Check if all emails in a category are selected, if yes, add category to selectedCategories
      categorizedEmployees.forEach((category, employees) {
        if (employees
            .every((employee) => selectedEmails.contains(employee.email))) {
          selectedCategories.add(category);
        } else {
          selectedCategories.remove(category);
        }
      });
    });
  }

  void _toggleCategorySelection(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
        // Remove all emails from the category when category checkbox is unchecked
        selectedEmails.removeWhere((email) => categorizedEmployees[category]!
            .map((employee) => employee.email)
            .contains(email));
      } else {
        selectedCategories.add(category);
        // Add all emails from the category when category checkbox is checked
        selectedEmails.addAll(
            categorizedEmployees[category]!.map((employee) => employee.email));
      }
    });
  }

  void _toggleSelectAll(bool? value) {
    if (value != null) {
      setState(() {
        selectAll = value;
        if (value) {
          selectedEmails.addAll(employees.map((employee) => employee.email));
          selectedCategories.addAll(categorizedEmployees.keys);
        } else {
          selectedEmails.clear();
          selectedCategories.clear();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double listWidth = screenWidth < 600 ? screenWidth * 0.9 : 600;
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                width: listWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormFieldWidget(
                      obSecureText: false,
                      keyboardType: TextInputType.text,
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Email description is required';
                        }
                      },
                      controller: descriptionController,
                      labelText: 'Email description',
                      hintText: 'enter email description',
                      icon: const Icon(
                        Icons.person,
                        color: clrGreenOriginal,
                      ),
                      maxLength: 300,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: selectAll,
                          onChanged: _toggleSelectAll,
                        ),
                        SizedBox(width: 8),
                        Text('Select All'),
                      ],
                    ),
                    SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: categorizedEmployees.length,
                      itemBuilder: (context, index) {
                        final category = categorizedEmployees.keys.elementAt(index);
                        final categoryEmployees = categorizedEmployees[category]!;

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: Checkbox(
                                  value: selectedCategories.contains(category),
                                  onChanged: (value) {
                                    _toggleCategorySelection(category);
                                  },
                                ),
                                title: Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: categoryEmployees.length,
                                itemBuilder: (context, index) {
                                  final employee = categoryEmployees[index];
                                  return ListTile(
                                    title: Text(
                                        '${employee.firstName} ${employee.lastName}'),
                                    subtitle: Text(employee.email),
                                    leading: Checkbox(
                                      value:
                                          selectedEmails.contains(employee.email),
                                      onChanged: (value) {
                                        _toggleSelection(employee.email);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _sendEmail,
          child: Icon(Icons.send),
        ));
  }

  void _sendEmail() async {
    if (selectedEmails.isNotEmpty) {
      final apiUrl = '$apiPrefix/email/shiftcreated';
      final receiverEmail = selectedEmails.join(', ');
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'reciverEmail': receiverEmail,
          'subject': 'shifttime',
          'description': descriptionController.text,
        },
      );

      if (response.statusCode == 200) {
        // Email sent successfully
        _showSnackbar('Email sent successfully.', clrGreenOriginal);
        print('Email sent successfully.');
      } else {
        _showSnackbar(
            'Failed to send email. Status code: ${response.statusCode}',
            Colors.red);
        // Handle error response
        print('Failed to send email. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } else {
      print('No emails selected.');
      _showSnackbar('No emails selected.', Colors.red);
    }
  }
}

class Employee {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String gender;
  final String role;
  final String userName;
  final String? category;

  Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.role,
    required this.userName,
    required this.category,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      gender: json['gender'],
      role: json['role'],
      userName: json['userName'],
      category: json['category'] ?? '',
    );
  }
}
