import 'package:workout_skripsi_app/service/CommonService/export_service.dart';
import 'package:workout_skripsi_app/service/InitialService/pickLocation_service.dart';

class PickLocationPage extends StatefulWidget {
  const PickLocationPage({super.key});

  @override
  _PickLocationPageState createState() => _PickLocationPageState();
}

class _PickLocationPageState extends State<PickLocationPage> {
  final PickLocationService _pickLocationService = PickLocationService();
  final userController = Get.find<UserController>();
  bool _isLoading = false;
  int _selectedLocation = -1;

  final List<String> location = ["Gym", 'home_loc'.tr];

  void _setLoading(bool value) {
    if (!mounted) return;
    setState(() {
      _isLoading = value;
    });
  }

  void _selectLocation(int index) {
    setState(() {
      _selectedLocation = index;
    });
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
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Text(
                    'pick_location'.tr,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'used_for_routines'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  for (int i = 0; i < location.length; i++)
                    buildSelectOption(
                      title: location[i],
                      isSelected: _selectedLocation == i,
                      onPressed: () => _selectLocation(i),
                    ),
                  const SizedBox(height: 20),
                  buildCustomButton(
                    label: 'continue'.tr,
                    isLoading: _isLoading,
                    onPressed: _selectedLocation == -1 || _isLoading
                        ? null
                        : () => _pickLocationService.continueNextPage(
                              userId: userController.userId.value,
                              selectedLocation: _selectedLocation,
                              setLoading: _setLoading,
                            ),
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
