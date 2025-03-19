import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/view/InitialView/pickgoal_view.dart';

class InputDataService {
  Future<void> submitMeasurements({
  required BuildContext context,
  required String userId,
  String? height,
  String? weight,
  String? selectedGender,
  required bool isInitial,
  Function(bool)? setLoading, // Make it optional
}) 
  async {
    final RegExp intPattern = RegExp(r'^\d+$');

    if (isInitial) {
      if (height == null || height.isEmpty || weight == null || weight.isEmpty) {
        showSnackBarMessage('Invalid Data!','Height and weight are required.');
        return;
      }
    }

    if (height != null && height.isNotEmpty && !intPattern.hasMatch(height)) {
      showSnackBarMessage('Invalid Data!', 'Height must be a whole number (integer only).');
      return;
    }
    if (weight != null && weight.isNotEmpty && !intPattern.hasMatch(weight)) {
      showSnackBarMessage('Invalid Data!','Weight must be a whole number (integer only).');
      return;
    }

    setLoading?.call(true); 

    final Uri fetchUrl = UrlConfig.getApiUrl('user/measurements/$userId');

    try {
      final Map<String, dynamic> requestBody = {};

      if (height != null && height.isNotEmpty) {
        requestBody['height'] = int.parse(height);
      }
      if (weight != null && weight.isNotEmpty) {
        requestBody['weight'] = int.parse(weight);
      }

      if (requestBody.isEmpty) {
        showSnackBarMessage('Error!','No data to update.');
        setLoading?.call(false);
        return;
      }

      final response = await http.put(
        fetchUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      setLoading?.call(false);

      if (response.statusCode == 200) {
        if (isInitial) {
          showSnackBarMessage('Success!', 'Measurements updated successfully!', success: true);
          Get.off(() => PickGoalPage());
        } else {
          String text = (height != null && height.isNotEmpty) ? "Height" : "Weight";
          showSnackBarMessage('Success!','$text updated successfully!', success: true);
        }
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        showSnackBarMessage('Failed!',responseData['message'] ?? 'Failed to update measurements');
      }
    } catch (e) {
      setLoading?.call(false);
      showSnackBarMessage('Error: Unable to connect to the server',  'There is an error when connecting to the server');
    }
  }
}

void showHeightBottomSheet(BuildContext context, String UserId, String height, Function(String) onHeightSelected, bool updateOnSave) {
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
                      final inputDataService = InputDataService();

                      await inputDataService.submitMeasurements(context: context, userId: UserId, height: selectedMainHeight.toString(), isInitial: false);
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

void showWeightBottomSheet(BuildContext context, String UserId, String weight, Function(String) onWeightSelected, bool updateOnSave) {
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
                  onPressed: () async {
                    if (updateOnSave == true){
                      final inputDataService = InputDataService();

                      await inputDataService.submitMeasurements(context: context, userId: UserId, weight: selectedMainWeight.toString(), isInitial: false);
                    }
                    await onWeightSelected("$selectedMainWeight"); 
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