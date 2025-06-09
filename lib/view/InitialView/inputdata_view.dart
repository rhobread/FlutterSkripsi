import 'package:workout_skripsi_app/service/CommonService/export_service.dart';
import 'package:workout_skripsi_app/service/InitialService/inputdata_service.dart';

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

    const genderMap = {
      'Male': 'Male',
      'Pria': 'Male',
      'Female': 'Female',
      'Wanita': 'Female',
    };

    final String normalizedGender = genderMap[_selectedGender] ?? '';

    _inputDataService.submitMeasurements(
      context: context,
      userId: userController.userId.value,
      height: height,
      weight: weight,
      selectedGender: normalizedGender,
      setLoading: _setLoading,
      isInitial: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildMainHeader(context: context),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Text(
                    'input_your_data'.tr,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'used_for_routines'.tr,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Weight Field
                  buildTextField(
                    controller: _weightController,
                    labelText: 'weight'.tr + ' (kg)',
                    icon: Icons.fitness_center,
                    isNumeric: true,
                    trailingIcon: Icons.edit,
                    onIconTap: () {
                      showWeightBottomSheet(
                          context,
                          userController.userId.value,
                          _weightController.text,
                          (newWeight) {
                            setState(() {
                              _weightController.text = newWeight;
                            });
                          } as Function(String p1),
                          false);
                    },
                  ),
                  const SizedBox(height: 15),

                  // Height Field
                  buildTextField(
                      controller: _heightController,
                      labelText: 'height'.tr + ' (cm)',
                      icon: Icons.height,
                      isNumeric: true,
                      trailingIcon: Icons.edit,
                      onIconTap: () {
                        showHeightBottomSheet(
                            context,
                            userController.userId.value,
                            _heightController.text,
                            (newWeight) {
                              setState(() {
                                _heightController.text = newWeight;
                              });
                            } as Function(String p1),
                            false);
                      }),
                  const SizedBox(height: 15),

                  // Gender Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: InputDecoration(
                      labelText: 'gender'.tr,
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
                    items: ['gender_male'.tr, 'gender_female'.tr]
                        .map((String gender) {
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
                    label: 'continue'.tr,
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
