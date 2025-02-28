import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_1/view/picklocation.dart';

class PickAvailabilityPage extends StatefulWidget {
  final String userId;

  const PickAvailabilityPage({super.key, required this.userId});

  @override
  _PickAvailabilityPageState createState() => _PickAvailabilityPageState();
}

class _PickAvailabilityPageState extends State<PickAvailabilityPage> {
  final List<String> _daysOfWeek = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];

  final Map<int, bool> _selectedDays = {};
  final Map<int, TextEditingController> _minutesControllers = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 7; i++) {
      _selectedDays[i] = false;
      _minutesControllers[i] = TextEditingController();
    }
  }

  Future<void> _submitAvailability() async {
    List<int> daysAvailable = [];
    List<int> minutesAvailable = [];
    String setUserId = widget.userId;

    for (int i = 0; i < 7; i++) {
      if (_selectedDays[i] == true) {
        daysAvailable.add(i);
        minutesAvailable.add(int.tryParse(_minutesControllers[i]!.text) ?? 0);
      }
    }

    setState(() {
      _isLoading = true;
    });

    final Uri url =
        Uri.parse('http://10.0.2.2:3005/user/availabilities/${widget.userId}');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'days_available': daysAvailable,
          'minutes_available': minutesAvailable,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        _showMessage('Availability updated successfully!', success: true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => PickLocationPage(userId: setUserId)),
        );
      } else {
        _showMessage('Failed to update availability');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('Error: Unable to connect to the server');
    }
  }

  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<int> displayOrder = [1, 2, 3, 4, 5, 6, 0];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            color: Colors.black,
            height: 80,
            width: double.infinity,
            alignment: Alignment.center,
            child: const SafeArea(
              child: Text(
                'GymTits',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                children: [
                  // Title with subtitle
                  const Text(
                    'Select Your Availability',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Used to plan your training schedule, won\'t be shared!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  Column(
                    children: displayOrder.map((index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _selectedDays[index],
                              onChanged: (bool? value) {
                                setState(() {
                                  _selectedDays[index] = value ?? false;
                                });
                              },
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              flex: 3,
                              child: Text(
                                _daysOfWeek[index],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 50, // Adjusted height for a better look
                                child: TextField(
                                  controller: _minutesControllers[index],
                                  keyboardType: TextInputType.number,
                                  enabled: _selectedDays[index],
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    labelText:
                                        'Minutes', // Floating label effect
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8)), // Rounded border
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitAvailability,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Submit'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.black,
            height: 30,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
