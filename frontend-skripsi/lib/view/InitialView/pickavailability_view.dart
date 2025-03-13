import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:flutter_application_1/service/InitialService/pickavailability_service.dart';

class PickAvailabilityPage extends StatefulWidget {
  const PickAvailabilityPage({super.key});

  @override
  _PickAvailabilityPageState createState() => _PickAvailabilityPageState();
}

class _PickAvailabilityPageState extends State<PickAvailabilityPage> {
  final userController = Get.find<UserController>();

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

  final PickAvailabilityService _pickAvailabilityService =
      PickAvailabilityService();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 7; i++) {
      _selectedDays[i] = false;
      _minutesControllers[i] = TextEditingController();
    }
  }

  void _setLoading(bool value) {
    if (!mounted) return;
    setState(() {
      _isLoading = value;
    });
  }

  void _submitAvailability() {
    _pickAvailabilityService.submitAvailability(
      context: context,
      userId: userController.userId.value,
      selectedDays: _selectedDays,
      minutesControllers: _minutesControllers,
      setLoading: _setLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<int> displayOrder = [1, 2, 3, 4, 5, 6, 0];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          buildMainHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                children: [
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
                            const SizedBox(width: 10),
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
                                height: 50,
                                child: TextField(
                                  controller: _minutesControllers[index],
                                  keyboardType: TextInputType.number,
                                  enabled: _selectedDays[index],
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    labelText: 'Minutes',
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
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
                  buildCustomButton(
                    label: 'Submit',
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _submitAvailability,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          buildMainFooter(),
        ],
      ),
    );
  }
}
