import 'package:flutter/material.dart';

void main() {
  runApp(UserSettingScreen());
}

class UserSettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Editable Fields Example'),
        ),
        body: EditableFields(),
      ),
    );
  }
}

class EditableFields extends StatefulWidget {
  @override
  _EditableFieldsState createState() => _EditableFieldsState();
}

class _EditableFieldsState extends State<EditableFields> {
  TextEditingController _field1Controller = TextEditingController();
  TextEditingController _field2Controller = TextEditingController();
  TextEditingController _field3Controller = TextEditingController();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Initialize values for non-editable fields
    _field1Controller.text = 'Value 1';
    _field2Controller.text = 'Value 2';
    _field3Controller.text = 'Value 3';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildNonEditableField('Field 1', _field1Controller),
          buildNonEditableField('Field 2', _field2Controller),
          buildNonEditableField('Field 3', _field3Controller),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                // Toggle editing mode
                _isEditing = !_isEditing;
                // Clear text fields when entering edit mode
                if (_isEditing) {
                  _field1Controller.clear();
                  _field2Controller.clear();
                  _field3Controller.clear();
                }
              });
            },
            child: Text(_isEditing ? 'Save' : 'Edit'),
          ),
        ],
      ),
    );
  }

  Widget buildNonEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Text('$label:'),
          SizedBox(width: 10),
          Expanded(
            child: _isEditing
                ? TextFormField(
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            )
                : Text(controller.text),
          ),
        ],
      ),
    );
  }
}
