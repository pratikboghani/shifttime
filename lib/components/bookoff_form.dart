import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shifttime/utilities/text_form_field_widget.dart';
import 'package:http/http.dart' as http;
import '../models/bookoffDetails.dart';
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
  List<BookoffRequest> bookoffRequests = [];

  void _showSnackbar(String message,Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),

      duration: const Duration(seconds: 2),
      backgroundColor: color,
    ));
  }
  Future<void> submitBookoffRequest() async {
    final String apiUrl = '$apiPrefix/bookoff/create';

    Map<String, dynamic> requestData = {
      'userId': userId,
      'clientId': clientId,
      'start_date': fController.text,
      'end_date': tController.text,
      'reasons': daysController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode(requestData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Request successful!');
        _showSnackbar('Request successful!',Colors.green);
      } else {
        print('Request failed with status: ${response.statusCode}');
        _showSnackbar('Request failed with status: ${response.statusCode}',Colors.red);

      }
    } catch (e) {
      print('Error: $e');
      _showSnackbar('Error: $e',Colors.red);
    }
    await fetchBookoffRequests();
  }

  Future<void> fetchBookoffRequests() async {
    final String apiUrl = '$apiPrefix/bookoff/?query={"userId": "$userId", "clientId": $clientId}';
print(apiUrl);
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData != null && responseData['response'] != null) {
          final List<dynamic> requestsList = responseData['response']['docs'];

          // Check if requestsList is not null before mapping
          if (requestsList != null) {
            bookoffRequests = requestsList.map((data) => BookoffRequest.fromJson(data)).toList();
          }
        }

        setState(() {});
      } else {
        print('Failed to fetch bookoff1 requests with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error while fetching bookoff requests: $e');
    }
  }
  int calculateDaysDifference(String startDateString, String endDateString) {
    try {
      final DateFormat formatter = DateFormat("dd-MM-yyyy");
      final DateTime startDate = formatter.parse(startDateString);
      final DateTime endDate = formatter.parse(endDateString);

      final Duration difference = endDate.difference(startDate);
      return difference.inDays+2;
    } catch (e) {
      print("Error calculating days difference: $e");
      return 0;
    }
  }
  @override
  void initState() {
    super.initState();
    fetchBookoffRequests();
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double listWidth = screenWidth < 600 ? screenWidth * 0.9 : 600;
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: listWidth,
            child: Column(
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
                    onPressed: () => submitBookoffRequest(),
                  ),
                ),

                if (bookoffRequests.isNotEmpty)
                  SingleChildScrollView(
                    child: Column(
                      children: bookoffRequests.map((request) {

                        return Card(
                          color: request.isApproved ? clrGreenWhite90 : Colors.red.shade50,
                          child: ListTile(
                            title: Text('${request.isApproved ? 'Approved' : 'Approval Pending'} \nReason: ${request.reasons}'),
                            subtitle: Text(
                              'Period: ${request.startDate} To ${request.endDate} \nDays: ${calculateDaysDifference(request.startDate, request.endDate)}',
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),

    );
  }
}
