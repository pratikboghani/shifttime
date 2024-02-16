import 'package:flutter/material.dart';
import 'package:shifttime/utilities/constants.dart';
import 'package:shifttime/utilities/raised_button_widget.dart';
import 'package:shifttime/utilities/text_form_field_widget.dart';
import 'package:shifttime/utilities/time_picker.dart';

class CategoryForm extends StatefulWidget {
  const CategoryForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CategoryFormState createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController sundayTController = TextEditingController();
  final TextEditingController mondayFController = TextEditingController();
  final TextEditingController mondayTController = TextEditingController();
  final TextEditingController tuesdayFController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: RaisedButtonWidget(
          //     bgColor: clrGreenOriginal,
          //     buttonText: 'Add Availability',
          //     buttonTextColor: clrWhite,
          //     onPressed: () => _showAddAvailabilityPopup(context),
          //   ),
          // ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAddAvailabilityPopup(context),child: const Icon(Icons.add)),
    );
  }

  Future<void> _showAddAvailabilityPopup(BuildContext context) async {
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
                      child: TextFormFieldWidget(labelText: 'Category', hintText: 'enter category', icon: Icon(Icons.category), keyboardType: TextInputType.text, validator: (){}, controller: categoryController, maxLength: 100)
                    ),
                  ],
                ),
                // Add similar Rows for other days if needed
                const SizedBox(height: 16),
                RaisedButtonWidget(
                  buttonText: 'Save',
                  buttonTextColor: clrWhite,
                  bgColor: clrGreenOriginal,
                  onPressed: () {
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
}

