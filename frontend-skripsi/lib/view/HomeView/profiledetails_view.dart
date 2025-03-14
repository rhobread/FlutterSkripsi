import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:flutter_application_1/service/HomeService/profiledetails_service.dart';

class ProfileDetailsPage extends StatefulWidget {
  final String userId;
  const ProfileDetailsPage({super.key, required this.userId});

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  final profileService = ProfileDetailsService();
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
      final userData = await profileService.getUserDetails(
        context: context, 
        userId: widget.userId,
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
                        buildProfileItem(context, Icons.wc, "Gender", gender,
                            Colors.deepOrangeAccent, _showGenderBottomSheet),
                        buildProfileItem(
                            context,
                            Icons.monitor_weight,
                            "Current Weight",
                            weight,
                            Colors.green,
                            _showWeightBottomSheet),
                        buildProfileItem(
                            context,
                            Icons.height,
                            "Height",
                            height,
                            Colors.lightBlueAccent,
                            _showHeightBottomSheet),
                      ]),
                    ],
                  ),
                ),
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
    double currentHeight = double.tryParse(height.split(" ")[0]) ?? 170.0;
    int mainHeight =
        currentHeight.floor(); // Get main height (e.g., 170 from 170.5)
    int decimalHeight = ((currentHeight - mainHeight) * 10)
        .round(); // Get decimal part (e.g., 5 from 170.5)

    FixedExtentScrollController mainController = FixedExtentScrollController(
        initialItem: mainHeight - 140); // Min 140 cm
    FixedExtentScrollController decimalController =
        FixedExtentScrollController(initialItem: decimalHeight); // 0 to 9

    int selectedMainHeight = mainHeight;
    int selectedDecimalHeight = decimalHeight;

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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Main Height Scroll
                        SizedBox(
                          width: 80,
                          child: ListWheelScrollView.useDelegate(
                            controller: mainController,
                            itemExtent: 50,
                            perspective: 0.005,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                selectedMainHeight =
                                    index + 140; // 140 to 200 cm
                              });
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, index) {
                                return Center(
                                  child: Text(
                                    "${index + 140}",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: (index + 140) == selectedMainHeight
                                          ? Colors.blue
                                          : Colors.black,
                                    ),
                                  ),
                                );
                              },
                              childCount: 61, // 140 to 200 cm
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
                        // Decimal Height Scroll
                        SizedBox(
                          width: 50,
                          child: ListWheelScrollView.useDelegate(
                            controller: decimalController,
                            itemExtent: 50,
                            perspective: 0.005,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                selectedDecimalHeight = index; // 0 to 9
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
                                      color: index == selectedDecimalHeight
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
                          "cm",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        height =
                            "$selectedMainHeight.$selectedDecimalHeight cm"; // Update height
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
}
