import 'package:flutter/material.dart';
import 'package:flutter_application_1/view/pickavailability.dart';

class PickGoalPage extends StatefulWidget {
  final String userId;

  const PickGoalPage({super.key, required this.userId});

  @override
  _PickGoalPageState createState() => _PickGoalPageState();
}

class _PickGoalPageState extends State<PickGoalPage> {
  bool _isLoading = false;
  int _selectedGoal = -1; // -1 means no selection

  final List<String> goals = [
    "Maintenance",
    "Muscle Gain / Bulking",
    "Weight Loss"
  ];

  Future<void> _continueNextPage() async {
    String setUserId = widget.userId;
    setState(() {
      _isLoading = true;
    });

    try {
      setState(() {
        _isLoading = false;
      });
      _showMessage('Goal Picked!', success: true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => PickAvailabilityPage(userId: setUserId)),
      );
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

  void _selectGoal(int index) {
    setState(() {
      _selectedGoal = index;
    });
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
                'JymMat',
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
                      'Pick your goal!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    const Text(
                      'Used to generate your routines, won\'t be shared!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Goal Selection Buttons
                    for (int i = 0; i < goals.length; i++)
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _selectGoal(i),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: _selectedGoal == i
                                ? Colors.black
                                : Colors.white,
                            side:
                                const BorderSide(color: Colors.black, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: Text(
                            goals[i],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _selectedGoal == i
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedGoal == -1 || _isLoading
                            ? null
                            : _continueNextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Continue'),
                      ),
                    ),
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
