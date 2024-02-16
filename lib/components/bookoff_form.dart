import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shifttime/utilities/text_form_field_widget.dart';

class BookoffForm extends StatefulWidget {
  const BookoffForm({Key? key}) : super(key: key);

  @override
  State<BookoffForm> createState() => _BookoffFormState();

}

class _BookoffFormState extends State<BookoffForm> {
  final TextEditingController daysController = TextEditingController();
  final TextEditingController sundayFController = TextEditingController();
  final TextEditingController sundayTController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormFieldWidget(labelText: "How many days of bookoff", hintText: 'Ex. 5', icon: Icon(Icons.numbers), keyboardType: TextInputType.number, validator: (){}, controller: daysController, maxLength: 100),
      )
    ],),);
  }
}
