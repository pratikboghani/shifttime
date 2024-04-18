import 'dart:convert';
import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../utilities/constants.dart';

class ManageBookoff extends StatefulWidget {
  const ManageBookoff({Key? key}) : super(key: key);

  @override
  State<ManageBookoff> createState() => _ManageBookoffState();
}

class _ManageBookoffState extends State<ManageBookoff> {
  List<dynamic> bookoffList = [];
  String showApproved = "All";
  @override
  void initState() {
    super.initState();
    _fetchbookoff();
  }

  Future<void> _fetchbookoff() async {
    try {
      final http.Response response = await http.get(
        Uri.parse('$apiPrefix/bookoff?query=${_getQuery()}'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> docs = responseBody['response']['docs'];
        setState(() {
          bookoffList = docs;
        });
        print(bookoffList);
      } else {
        print('Failed to fetch bookoffff. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching bookoff: $error');
    }
  }

  String _getQuery() {
    if (showApproved == "All") {
      return "{}";
    } else {
      return '{"isApproved": ${showApproved == "Approved"}}';
    }
  }
  Future<void> _showApprovalDialog(dynamic bookoff) async {
    bool isCurrentlyApproved = bookoff['isApproved'];

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Mark as ${isCurrentlyApproved ? 'Not Approved' : 'Approved'}?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Do you want to mark this request as ${isCurrentlyApproved ? 'not approved' : 'approved'}?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _markAsApproved(bookoff['_id'], isCurrentlyApproved);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Mark as ${isCurrentlyApproved ? 'Not Approved' : 'Approved'}'),
            ),
          ],
        );
      },
    );
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

  Future<void> _markAsApproved(String bookoffId, bool isCurrentlyApproved) async {
    try {
      final http.Response response = await http.put(
        Uri.parse('$apiPrefix/bookoff/$bookoffId'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({
          'isApproved': !isCurrentlyApproved, // Toggle the approval status
        }),
      );

      if (response.statusCode == 200) {
        print('Marked as ${!isCurrentlyApproved ? 'Approved' : 'Not Approved'} successfully');
        _fetchbookoff();
      } else {
        print('Failed to mark as ${!isCurrentlyApproved ? 'Approved' : 'Not Approved'}. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error marking as ${!isCurrentlyApproved ? 'Approved' : 'Not Approved'}: $error');
    }
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double listWidth = screenWidth < 600 ? screenWidth * 0.9 : 600;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            SizedBox(
              width: listWidth,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  value: showApproved,
                  items: ["All", "Approved", "Pending"].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    hintText: '',
                    labelText: '',
                    prefixIcon: Icon(
                      Icons.category,
                      color: clrGreenOriginal,
                    ),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      showApproved = newValue ?? "All";
                      _fetchbookoff();
                    });
                  },
                ),
              ),
            ),
            Column(
              children: bookoffList.map((bookoff) {

                bool isApproved = bookoff['isApproved'] ?? false;


                return GestureDetector(
                  onDoubleTap: (){
                    _showApprovalDialog(bookoff);
                  },
                  child: Center(
                    child: Container(
                      width: listWidth,
                      child: Card(
                        margin: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,

                        color: isApproved ? clrGreenWhite90 : Colors.red.shade50, // Change color based on approval status
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: ListTile(
                            title: Text('${isApproved ? 'Approved' : 'Approval Pending'} \nReason: ${bookoff['reasons']}'),
                            subtitle: Text(
                              'Period: ${bookoff['start_date']} To ${bookoff['end_date']} \nDays: ${calculateDaysDifference(bookoff['start_date'], bookoff['end_date'])}',

                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

          ],
        ),
      ),
    );
  }
}
