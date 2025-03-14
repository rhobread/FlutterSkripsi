import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/view/InitialView/pickgoal_view.dart';

class InputDataService {
  Future<void> submitMeasurements({
    required BuildContext context,
    required String userId,
    required String height,
    required String weight,
    required String? selectedGender,
    required Function(bool) setLoading,
  }) async {
    // Validate input fields
    if (height.isEmpty || weight.isEmpty || selectedGender == null) {
      showSnackBarMessage(context, 'All fields are required.');
      return;
    }

    setLoading(true);
    final Uri fetchUrl = UrlConfig.getApiUrl('user/measurements/$userId');

    try {
      final response = await http.put(
        fetchUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'height': int.tryParse(height) ?? 0,
          'weight': int.tryParse(weight) ?? 0,
        }),
      );

      setLoading(false);

      if (response.statusCode == 200) {
        showSnackBarMessage(context, 'Measurements updated successfully!',
            success: true);

        Get.off(() => PickGoalPage());
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        showSnackBarMessage(context,
            responseData['message'] ?? 'Failed to update measurements');
      }
    } catch (e) {
      setLoading(false);
      showSnackBarMessage(context, 'Error: Unable to connect to the server');
    }
  }
}

void showHeightBottomSheet(BuildContext context, String height, Function(String) onHeightSelected, bool updateOnSave) {
  int currentHeight = int.tryParse(height.split(" ")[0]) ?? 170;

  FixedExtentScrollController mainController =
      FixedExtentScrollController(initialItem: currentHeight - 140); 
  int selectedMainHeight = currentHeight;

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
                  "Select Height (cm)",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Main Height Scroll
                      SizedBox(
                        width: 100,
                        child: ListWheelScrollView.useDelegate(
                          controller: mainController,
                          itemExtent: 50,
                          perspective: 0.005,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            setModalState(() {
                              selectedMainHeight = index + 140;
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
                            childCount: 61, 
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (updateOnSave == true){
                      updateOnSave = false;
                    }
                    await onHeightSelected("$selectedMainHeight"); 
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

void showWeightBottomSheet(
    BuildContext context, String weight, Function(String) onWeightSelected, bool updateOnSave) {
  int currentWeight = int.tryParse(weight.split(" ")[0]) ?? 70;

  FixedExtentScrollController mainController =
      FixedExtentScrollController(initialItem: currentWeight - 30); // Min 30 kg

  int selectedMainWeight = currentWeight;

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
                  "Select Weight (kg)",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Main Weight Scroll
                      SizedBox(
                        width: 100,
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
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    onWeightSelected("$selectedMainWeight"); // ✅ Callback to update weight
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