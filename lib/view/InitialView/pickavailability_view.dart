import 'package:workout_skripsi_app/service/CommonService/export_service.dart';
import 'package:workout_skripsi_app/service/InitialService/pickAvailability_service.dart';
import 'package:workout_skripsi_app/view/InitialView/picklocation_view.dart';

class PickAvailabilityPage extends StatefulWidget {
  final bool isUpdateAvailability;
  const PickAvailabilityPage({super.key, required this.isUpdateAvailability});

  @override
  _PickAvailabilityPageState createState() => _PickAvailabilityPageState();
}

class _PickAvailabilityPageState extends State<PickAvailabilityPage> {
  final userController = Get.find<UserController>();
  final PickAvailabilityService _pickAvailabilityService =
      PickAvailabilityService();

  // 1) Keys in English for backend matching
  final List<String> _dayKeys = [
    'sunday',
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
  ];

  // 2) Localized labels for display
  late final List<String> _daysOfWeek = _dayKeys.map((k) => k.tr).toList();

  // State
  List<Map<String, dynamic>> _userAvailability = [];
  final Map<int, bool> _selectedDays = {};
  final Map<int, TextEditingController> _minutesControllers = {};
  bool _isLoading = false;
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    // initialize maps
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
    final availability = await _pickAvailabilityService.getUserAvailability(
      userId: userController.userId.value,
    );

    setState(() {
      _userAvailability = availability;
      for (var entry in _userAvailability) {
        final dayKey = (entry['day'] as String).toLowerCase();
        final minutes = entry['minutes'] as int;
        final index = _dayKeys.indexWhere((k) => k == dayKey);
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
    setState(() => _isLoading = value);
  }

  Future<void> _submitAvailability() async {
    // Clean up any selected day without minutes
    for (int i = 0; i < _dayKeys.length; i++) {
      if (_selectedDays[i] == true &&
          _minutesControllers[i]?.text.trim().isEmpty == true) {
        _selectedDays[i] = false;
      }
    }

    // Validate at least one day selected
    if (!_selectedDays.values.any((sel) => sel)) {
      Get.snackbar(
        'validation_error'.tr,
        'day_val_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await _pickAvailabilityService.submitAvailability(
      userId: userController.userId.value,
      selectedDays: _selectedDays,
      minutesControllers: _minutesControllers,
      isUpdateAvailability: widget.isUpdateAvailability,
      setLoading: _setLoading,
    );

    if (widget.isUpdateAvailability) {
      Get.back();
      showSnackBarMessage('success'.tr, 'success_update_availability'.tr,
          success: true);
    } else {
      Get.off(() => PickLocationPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayOrder = [1, 2, 3, 4, 5, 6, 0];

    return Scaffold(
      appBar: buildMainHeader(
        showBackButton: widget.isUpdateAvailability,
        context: context,
      ),
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
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
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
                                    onChanged: (bool? val) {
                                      setState(() {
                                        _selectedDays[index] = val ?? false;
                                        if (val == false) {
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
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
