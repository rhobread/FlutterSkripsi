import 'package:workout_skripsi_app/service/CommonService/export_service.dart';
import 'package:workout_skripsi_app/service/InitialService/pickAvailability_service.dart';

class PickAvailabilityPage extends StatefulWidget {
  final bool isUpdateAvailability;
  const PickAvailabilityPage({super.key, required this.isUpdateAvailability});

  @override
  _PickAvailabilityPageState createState() => _PickAvailabilityPageState();
}

class _PickAvailabilityPageState extends State<PickAvailabilityPage> {
  final userController = Get.find<UserController>();
  List<Map<String, dynamic>> _useravailability = [];

  final List<String> _daysOfWeek = [
    'sunday'.tr,
    'monday'.tr,
    'tuesday'.tr,
    'wednesday'.tr,
    'thursday'.tr,
    'friday'.tr,
    'saturday'.tr
  ];

  final Map<int, bool> _selectedDays = {};
  final Map<int, TextEditingController> _minutesControllers = {};
  bool _isLoading = false;
  bool _isDataLoaded = false;

  final PickAvailabilityService _pickAvailabilityService =
      PickAvailabilityService();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 7; i++) {
      _selectedDays[i] = false;
      _minutesControllers[i] = TextEditingController();
    }
    if (widget.isUpdateAvailability) {
      _initializeAvailability();
    } else {
      _isDataLoaded = true;
    }
  }

  Future<void> _initializeAvailability() async {
    List<Map<String, dynamic>> availability =
        await _pickAvailabilityService.getUserAvailability(
      userId: userController.userId.value,
    );

    setState(() {
      _useravailability = availability;
      for (var entry in _useravailability) {
        String day = entry["day"];
        int minutes = entry["minutes"];

        int index =
            _daysOfWeek.indexWhere((d) => d.toLowerCase() == day.toLowerCase());
        if (index != -1) {
          _selectedDays[index] = true;
          _minutesControllers[index]?.text = minutes.toString();
        }
      }
      _isDataLoaded = true;
    });
  }

  void _setLoading(bool value) {
    if (!mounted) return;
    setState(() {
      _isLoading = value;
    });
  }

  void _submitAvailability() {
    // For each day, if selected but no minutes are provided, unselect it.
    for (int i = 0; i < _daysOfWeek.length; i++) {
      if (_selectedDays[i] == true &&
          _minutesControllers[i]?.text.trim().isEmpty == true) {
        _selectedDays[i] = false;
      }
    }

    // Validate that at least one availability is provided.
    if (!_selectedDays.values.any((selected) => selected)) {
      Get.snackbar(
        'validation_error'.tr,
        'day_val_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Proceed with the submission using the original parameters.
    _pickAvailabilityService.submitAvailability(
      userId: userController.userId.value,
      selectedDays: _selectedDays,
      minutesControllers: _minutesControllers,
      isUpdateAvailability: widget.isUpdateAvailability,
      setLoading: _setLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<int> displayOrder = [1, 2, 3, 4, 5, 6, 0];

    return Scaffold(
      appBar: buildMainHeader(
          showBackButton: widget.isUpdateAvailability, context: context),
      backgroundColor: Colors.white,
      body: _isDataLoaded
          ? Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    child: Column(
                      children: [
                        Text(
                          'select_avail'.tr,
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'used_for_schedule'.tr,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
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
                                        if (value == false) {
                                          _minutesControllers[index]?.clear();
                                        }
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
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        enabled: _selectedDays[index],
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          labelText: 'minutes'.tr,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8)),
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
                          label: 'submit'.tr,
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
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
