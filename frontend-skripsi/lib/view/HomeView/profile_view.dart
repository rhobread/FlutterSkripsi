import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:flutter_application_1/service/HomeService/profile_service.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final profileService = ProfileService();
  var _userData; // Change from List to Map
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
      final userData = await profileService.getUserDetails(
          context: context, userId: widget.userId);

      setState(() {
        _userData = userData; // Assign received user data
        gender = "Male";
        weight = _userData['weight'].toString();
        height = _userData['height'].toString();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showSnackBarMessage(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _userData == null
                ? const Center(
                    child: Text(
                      "Failed to load profile data",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView(
                    children: [
                      _buildProfileItem(
                        "availability",
                        availableEquipment,
                        () => _updateField(
                          "availability",
                          availableEquipment,
                          (newValue) => setState(
                            () => availableEquipment = newValue,
                          ),
                        ),
                      ),
                      _buildProfileItem(
                        "Available Equipment",
                        availableEquipment,
                        () => _updateField(
                          "Available Equipment",
                          availableEquipment,
                          (newValue) => setState(
                            () => availableEquipment = newValue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Basic Info",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      _buildProfileItem(
                          "Gender", gender, _showGenderBottomSheet),
                      _buildProfileItem(
                          "Current Weight", weight, _showWeightBottomSheet),
                      _buildProfileItem(
                          "Height", height, _showHeightBottomSheet),
                      const SizedBox(height: 20),
                    ],
                  ),
      ),
    );
  }

  void _updateField(
      String title, String currentValue, Function(String) onUpdate) {
    TextEditingController controller =
        TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update $title"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(hintText: "Enter new $title"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                onUpdate(controller.text);
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showWeightBottomSheet() {
    double currentWeight = double.tryParse(weight.split(" ")[0]) ?? 70.0;
    int mainWeight =
        currentWeight.floor(); // Get main weight (e.g., 80 from 80.7)
    int decimalWeight = ((currentWeight - mainWeight) * 10)
        .round(); // Get decimal part (e.g., 7 from 80.7)

    FixedExtentScrollController mainController =
        FixedExtentScrollController(initialItem: mainWeight - 30); // Min 30 kg
    FixedExtentScrollController decimalController =
        FixedExtentScrollController(initialItem: decimalWeight); // 0 to 9

    int selectedMainWeight = mainWeight;
    int selectedDecimalWeight = decimalWeight;

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
                    "Select Weight",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Main Weight Scroll
                        SizedBox(
                          width: 80,
                          child: ListWheelScrollView.useDelegate(
                            controller: mainController,
                            itemExtent: 50,
                            perspective: 0.005,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                selectedMainWeight = index + 30; // 30 to 200 kg
                              });
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, index) {
                                return Center(
                                  child: Text(
                                    "${index + 30}",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: (index + 30) == selectedMainWeight
                                          ? Colors.blue
                                          : Colors.black,
                                    ),
                                  ),
                                );
                              },
                              childCount: 171, // 30 to 200 kg
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          ".",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                        // Decimal Weight Scroll
                        SizedBox(
                          width: 50,
                          child: ListWheelScrollView.useDelegate(
                            controller: decimalController,
                            itemExtent: 50,
                            perspective: 0.005,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                selectedDecimalWeight = index; // 0 to 9
                              });
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, index) {
                                return Center(
                                  child: Text(
                                    "$index",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: index == selectedDecimalWeight
                                          ? Colors.blue
                                          : Colors.black,
                                    ),
                                  ),
                                );
                              },
                              childCount: 10, // 0 to 9
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "kg",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        weight =
                            "$selectedMainWeight.$selectedDecimalWeight kg"; // Update weight
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

  void _showHeightBottomSheet() {
    int currentHeight = int.tryParse(height.split(" ")[0]) ?? 170;
    int initialIndex = currentHeight - 140;
    FixedExtentScrollController scrollController =
        FixedExtentScrollController(initialItem: initialIndex);

    int selectedHeight = currentHeight; // ✅ Declare outside StatefulBuilder

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
                    "Select Height",
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
                          selectedHeight = index + 140;
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          return Center(
                            child: Text(
                              "${index + 140} cm",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: (index + 140) == selectedHeight
                                    ? Colors.blue
                                    : Colors.black,
                              ),
                            ),
                          );
                        },
                        childCount: 61,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        height =
                            "$selectedHeight cm"; // ✅ Correctly updates height
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
                        childCount: genders.length, // Only "Male" & "Female"
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        gender = genders[selectedIndex]; // Update gender
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

  Widget _buildProfileItem(String title, String value, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(title,
            style: const TextStyle(
                fontSize: 14, color: Color.fromARGB(255, 0, 0, 0))),
        subtitle: Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 16, color: Color.fromARGB(255, 0, 0, 0)),
        onTap: onTap,
      ),
    );
  }
}
