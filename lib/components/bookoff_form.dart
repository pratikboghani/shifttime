import 'package:flutter/material.dart';
import 'package:shifttime/utilities/text_form_field_widget.dart';

import '../utilities/constants.dart';
import '../utilities/date_picker.dart';
import '../utilities/raised_button_widget.dart';

class BookoffForm extends StatefulWidget {
  const BookoffForm({Key? key}) : super(key: key);

  @override
  State<BookoffForm> createState() => _BookoffFormState();
}

class _BookoffFormState extends State<BookoffForm> {
  final TextEditingController daysController = TextEditingController();
  final TextEditingController fController = TextEditingController();
  final TextEditingController tController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

          Row(
            children: [
              Expanded(
                child: DatePicker(
                  controller: fController,
                  hintText: 'From date',
                  labelText: 'from date',
                ),
              ),
              const Text('To'),
              Expanded(
                child: DatePicker(
                  controller: tController,
                  hintText: 'To date',
                  labelText: 'to date',
                ),
              ),

            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20,8,20,8),
            child: TextFormFieldWidget(
                labelText: "Reason for bookoff",
                hintText: 'Enter Reason',
                icon: const Icon(Icons.lightbulb_outline),
                keyboardType: TextInputType.number,
                validator: () {},
                controller: daysController,
                maxLength: 100),
          ),
          Padding(

            padding: const EdgeInsets.all(8.0),
            child: RaisedButtonWidget(
              bgColor: clrGreenOriginal,
              buttonText: 'Request Bookoff',
              buttonTextColor: clrWhite,
              onPressed: () => (),
            ),
          ),

        ],
      ),

    );
  }
}
