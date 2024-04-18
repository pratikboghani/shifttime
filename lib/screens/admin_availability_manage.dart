import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utilities/constants.dart';

class ManageAvailability extends StatefulWidget {
  const ManageAvailability({Key? key}) : super(key: key);

  @override
  State<ManageAvailability> createState() => _ManageAvailabilityState();
}

class _ManageAvailabilityState extends State<ManageAvailability> {
  List<dynamic> availabilityList = [];
  String showApproved = "All";
  @override
  void initState() {
    super.initState();
    _fetchAvailability();
  }

  Future<void> _fetchAvailability() async {
    try {
      final http.Response response = await http.get(
        Uri.parse('$apiPrefix/availability?query=${_getQuery()}'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> docs = responseBody['response']['docs'];
        setState(() {
          availabilityList = docs;
        });
      } else {
        print('Failed to fetch availability. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching availability: $error');
    }
  }

  String _getQuery() {
    if (showApproved == "All") {
      return "{}";
    } else {
      return '{"isApproved": ${showApproved == "Approved"}}';
    }
  }
  Future<void> _showApprovalDialog(dynamic availability) async {
    bool isCurrentlyApproved = availability['isApproved'];

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Mark as ${isCurrentlyApproved ? 'Not Approved' : 'Approved'}?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Do you want to mark this availability as ${isCurrentlyApproved ? 'not approved' : 'approved'}?'),
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
                _markAsApproved(availability['_id'], isCurrentlyApproved);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Mark as ${isCurrentlyApproved ? 'Not Approved' : 'Approved'}'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _markAsApproved(String availabilityId, bool isCurrentlyApproved) async {
    try {
      final http.Response response = await http.put(
        Uri.parse('$apiPrefix/availability/$availabilityId'),
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
        _fetchAvailability(); // Refresh the availability list after marking as approved/not approved
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
                      _fetchAvailability();
                    });
                  },
                ),
              ),
            ),
            Column(
              children: availabilityList.map((availability) {
                bool isApproved = availability['isApproved'];
                return GestureDetector(
                  onDoubleTap: (){
                    _showApprovalDialog(availability);
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
                          child: Table(
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(1),
                              2: FlexColumnWidth(1),
                            },
                            children: [
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Text(
                                        isApproved ? 'Approved' : 'Approval Pending',
                                      style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    ),
                                  ),
                                  Container(), // Empty cell to align with the start_time column
                                  Text('*Double click to change status'),
                                ],
                              ),
                              for (int i = 0; i < availability['availibilityDetails'].length; i++)
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text(
                                        '${availability['availibilityDetails'][i]['day_of_week']}',
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text('${availability['availibilityDetails'][i]['start_time']}'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text('${availability['availibilityDetails'][i]['end_time']}'),
                                    ),
                                  ],
                                ),
                            ],
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
