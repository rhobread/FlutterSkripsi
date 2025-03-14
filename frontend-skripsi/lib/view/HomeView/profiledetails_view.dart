import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:flutter_application_1/service/HomeService/profiledetails_service.dart';
import 'package:flutter_application_1/service/InitialService/inputdata_service.dart';

class ProfileDetailsPage extends StatefulWidget {
  const ProfileDetailsPage({super.key});

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  final profileService = ProfileDetailsService();
  final userController = Get.find<UserController>();
  String userId = "";
  var _userData;
  String availableEquipment = "1";
  String gender = "";
  String weight = "";
  String height = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      userId = userController.userId.value;;

      final userData = await profileService.getUserDetails(
        context: context, 
        userId: userId,
      );

      if (!mounted) return; 
      setState(() {
        _userData = userData; 
        gender = "Male";
        weight = _userData['weight'].toString();
        height = _userData['height'].toString();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return; 
      setState(() {
        _isLoading = false;
      });
      showSnackBarMessage(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("ME",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
              ? const Center(
                  child: Text(
                    "Failed to load profile data",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      buildSection("Available Days", [
                        buildSettingsTile(
                          context,
                          Icons.calendar_today,
                          "Available Days",
                          Colors.blue,
                        ),
                      ]),
                      buildSection("Available Equipment", [
                        buildSettingsTile(
                          context,
                          Icons.fitness_center,
                          "Available Equipment",
                          Colors.red,
                        ),
                      ]),
                      buildSection("Basic Info", [
                        buildProfileItem(
                            context, 
                            Icons.wc, 
                            "Gender", 
                            gender,
                            Colors.deepOrangeAccent, _showGenderBottomSheet),
                        buildProfileItem(
                            context,
                            Icons.monitor_weight,
                            "Current Weight",
                            weight + " kg",
                            Colors.green,
                            () {
                            showWeightBottomSheet(context, userId , weight, (newWeight) {
                              setState(() {
                                weight = newWeight; 
                              });
                            }, true);
                          }
                        ),
                        buildProfileItem(
                          context,
                          Icons.height,
                          "Height",
                          height,
                          Colors.lightBlueAccent,
                          () {
                            showHeightBottomSheet(context, userId, height, (newHeight) {
                              setState(() {
                                height = newHeight; 
                              });
                            }, true);
                          },
                        ),
                      ]),
                    ],
                  ),
                ),
    );
  }

  void _showGenderBottomSheet() {
    List<String> genders = ["Male", "Female"];
    int selectedIndex = genders.indexOf(gender); // Get current selection index
    FixedExtentScrollController scrollController =
        FixedExtentScrollController(initialItem: selectedIndex);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    "Select Gender",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      controller: scrollController,
                      itemExtent: 50,
                      perspective: 0.005,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setModalState(() {
                          selectedIndex = index; // Update selected index
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          return Center(
                            child: Text(
                              genders[index],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: index == selectedIndex
                                    ? Colors.blue
                                    : Colors.black,
                              ),
                            ),
                          );
                        },
                        childCount: genders.length, 
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        gender = genders[selectedIndex]; 
                      });
                      Navigator.pop(context);
                    },
                    child: const Text("Save"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
