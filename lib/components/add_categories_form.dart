import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shifttime/utilities/constants.dart';
import 'package:shifttime/utilities/raised_button_widget.dart';
import 'package:shifttime/utilities/text_form_field_widget.dart';
import 'package:http/http.dart' as http;

class CategoryForm extends StatefulWidget {
  const CategoryForm({super.key});
  @override
  _CategoryFormState createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  List<Map<String, dynamic>> userData = [];
  final TextEditingController categoryController = TextEditingController();

  Future<void> _showAddAvailabilityPopup(BuildContext context) async {
    categoryController.text='';
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: TextFormFieldWidget(
                            labelText: 'Category',
                            hintText: 'enter category',
                            icon: Icon(Icons.category),
                            keyboardType: TextInputType.text,
                            validator: (String value) {
                              if (value.isEmpty) {
                                return 'Category is required';
                              }
                            },
                            controller: categoryController,
                            maxLength: 100)),
                  ],
                ),
                // Add similar Rows for other days if needed
                const SizedBox(height: 16),
                RaisedButtonWidget(
                  buttonText: 'Save',
                  buttonTextColor: clrWhite,
                  bgColor: clrGreenOriginal,
                  onPressed: () {
                    setState(() {
                      _saveCategory();
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    clientId ??= '1001';
    _fetchCategories();
  }

  @override
  void _showSnackbar(String message,Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),

      duration: const Duration(seconds: 2),
      backgroundColor: color,
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(50.0),
      // ),
    ));
  }
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double listWidth = screenWidth < 600 ? screenWidth * 0.9 : 600;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
          ),
          Expanded(
            child: Center(
              child: Container(
                width: listWidth,
                child: ListView.builder(
                  itemCount: userData.length,
                  itemBuilder: (context, index) {
                    Category category = Category.fromJson(userData[index]);
                    return Card(
                        elevation: 3, // Adjust elevation as needed
                        margin: EdgeInsets.all(8), // Adjust margin as needed
                    child: ListTile(
                    title: Text(category.name),trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            setState(() {
                              _editCategory(category);
                            });

                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _deleteCategory(category.id);
                            });
                          },
                        ),
                      ],
                    ),
                    ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddAvailabilityPopup(context),
          child: const Icon(Icons.add)),
    );
  }
  Future<void> _fetchCategories() async {
    String apiUrl = '$apiPrefix/category/?query={"clientId": $clientId}';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> docs = responseData['response']['docs'];
      setState(() {
        userData = List<Map<String, dynamic>>.from(docs);
      });
    } else {}
  }
  Future<void> _saveCategory() async {
    // Get the category value from the text field
    String category = categoryController.text;
    // Define the API endpoint
    String apiUrl = '$apiPrefix/category/create/';

    // Define the request body
    Map<String, dynamic> requestBody = {
      'category': category,
      'clientId': clientId,
    };
    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode(requestBody),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Check the response status
      if (response.statusCode == 200) {
        _showSnackbar('Category saved successfully',Colors.green);
        _fetchCategories();
      } else {
        _showSnackbar('Failed to save category. Status code: ${response.statusCode}',Colors.red);

        print('Failed to save category. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      // Handle network error
      _showSnackbar('Error making HTTP request: $error',Colors.red);
    }

  }
  Future<void> _deleteCategory(String categoryId) async {
    String apiUrl = '$apiPrefix/category/$categoryId';

    try {
      var response = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );
      if (response.statusCode == 200) {
        _fetchCategories();
        _showSnackbar('Category deleted successfully',Colors.green);
      } else {
        _showSnackbar('Failed to delete category. Status code: ${response.statusCode}',Colors.red);
        print('Response body: ${response.body}');
      }
    } catch (error) {
      _showSnackbar('Error deleting category: $error',Colors.red);
    }
  }
  Future<void> _editCategory(Category category) async {

    // Implement edit functionality here
    // Open the update availability popup with the category details
    categoryController.text=category.name;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormFieldWidget(
                        labelText: 'Category',
                        hintText: 'enter category',
                        icon: Icon(Icons.category),
                        keyboardType: TextInputType.text,
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Category is required';
                          }
                        },
                        controller: categoryController,
                        maxLength: 100,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                RaisedButtonWidget(
                  buttonText: 'Update',
                  buttonTextColor: clrWhite,
                  bgColor: clrGreenOriginal,
                  onPressed: () {
                    // Call a method to handle the category update
                    _updateCategory(category.id, categoryController.text);
                    Navigator.of(context).pop(); // Close the popup
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Future<void> _updateCategory(String categoryId, String newCategoryName) async {
    String apiUrl = '$apiPrefix/category/$categoryId';
    Map<String, dynamic> requestBody = {
      'category': newCategoryName,
      'clientId': clientId,
    };

    try {
      var response = await http.put(
        Uri.parse(apiUrl),
        body: jsonEncode(requestBody),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      // Check the response status
      if (response.statusCode == 200) {
        // Category updated successfully, update the categories list
        _fetchCategories();
        _showSnackbar('Category updated successfully',Colors.green);
      } else {
        _showSnackbar('Failed to update category. Status code: ${response.statusCode}',Colors.red);
        print('Response body: ${response.body}');
      }
    } catch (error) {
      _showSnackbar('Error updating category: $error',Colors.red);
    }
  }
}

class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      name: json['category'],
    );
  }
}
