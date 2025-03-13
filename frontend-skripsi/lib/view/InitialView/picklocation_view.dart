import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:flutter_application_1/service/InitialService/picklocation_service.dart';

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

  final List<String> location = ["Gym", "Home"];

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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          buildMainHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    'Pick your location!',
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
                  for (int i = 0; i < location.length; i++)
                    buildSelectOption(
                      title: location[i],
                      isSelected: _selectedLocation == i,
                      onPressed: () => _selectLocation(i),
                    ),
                  const SizedBox(height: 20),
                  buildCustomButton(
                    label: 'Continue',
                    isLoading: _isLoading,
                    onPressed: _selectedLocation == -1 || _isLoading
                        ? null
                        : () => _pickLocationService.continueNextPage(
                              context: context,
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
