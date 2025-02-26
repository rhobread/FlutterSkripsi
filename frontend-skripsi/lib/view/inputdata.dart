import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_1/view/login.dart';

class InputDataPage extends StatefulWidget {
  final String userId;

  const InputDataPage({super.key, required this.userId});

  @override
  _InputDataPage createState() => _InputDataPage();
}

class _InputDataPage extends State<InputDataPage> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String? _selectedGender;

  bool _isLoading = false;

  Future<void> _submitMeasurements() async {
    final String height = _heightController.text.trim();
    final String weight = _weightController.text.trim();

    if (height.isEmpty || weight.isEmpty || _selectedGender == null) {
      _showMessage('All fields are required.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final Uri url =
        Uri.parse('http://10.0.2.2:3005/user/measurements/${widget.userId}');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'height': int.tryParse(height) ?? 0,
          'weight': int.tryParse(weight) ?? 0,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        _showMessage('Measurements updated successfully!', success: true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const LoginPage()), // Redirect after success
        );
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        _showMessage(
            responseData['message'] ?? 'Failed to update measurements');
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Black Header
          Container(
            color: Colors.black,
            height: 100,
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

          // Scrollable Form
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),

                    // Title
                    const Text(
                      'Input your data!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: const Text(
                        'Used to generate your routines, won\'t be shared!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    // Weight Field
                    TextField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg):',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 15),

                    // Height Field
                    TextField(
                      controller: _heightController,
                      decoration: const InputDecoration(
                        labelText: 'Height (cm):',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 15),

                    // Gender Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Gender:',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Male', 'Female'].map((String gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitMeasurements,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Continue'),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Black Footer
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
