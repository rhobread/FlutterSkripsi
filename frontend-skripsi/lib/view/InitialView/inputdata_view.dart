import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:flutter_application_1/service/InitialService/inputdata_service.dart';

class InputDataPage extends StatefulWidget {
  const InputDataPage({super.key});

  @override
  _InputDataPageState createState() => _InputDataPageState();
}

class _InputDataPageState extends State<InputDataPage> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final userController = Get.find<UserController>();

  String? _selectedGender;
  bool _isLoading = false;
  final InputDataService _inputDataService = InputDataService();

  void _setLoading(bool value) {
    if (!mounted) return;
    setState(() {
      _isLoading = value;
    });
  }

  void _submitMeasurements() {
    final String height = _heightController.text.trim();
    final String weight = _weightController.text.trim();

    _inputDataService.submitMeasurements(
      context: context,
      userId: userController.userId.value,
      height: height,
      weight: weight,
      selectedGender: _selectedGender,
      setLoading: _setLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          buildMainHeader(), // Use your existing header widget
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    'Input Your Data',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Used to generate your routines, won\'t be shared!',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Weight Field
                  buildTextField(
                    controller: _weightController,
                    labelText: 'Weight (kg)',
                    icon: Icons.fitness_center,
                  ),
                  const SizedBox(height: 15),

                  // Height Field
                  buildTextField(
                    controller: _heightController,
                    labelText: 'Height (cm)',
                    icon: Icons.height,
                  ),
                  const SizedBox(height: 15),

                  // Gender Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      prefixIcon:
                          const Icon(Icons.person, color: Colors.black54),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
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

                  // Submit Button using common widget
                  buildCustomButton(
                    label: 'Continue',
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _submitMeasurements,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          buildMainFooter(), // Use your existing footer widget
        ],
      ),
    );
  }
}
