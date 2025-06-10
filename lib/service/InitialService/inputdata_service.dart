import 'package:workout_skripsi_app/service/CommonService/export_service.dart';
import 'package:http/http.dart' as http;
import 'package:workout_skripsi_app/view/InitialView/pickAvailability_view.dart';

class InputDataService {
  Future<void> submitMeasurements({
    required BuildContext context,
    required String userId,
    String? height,
    String? weight,
    String? selectedGender,
    required bool isInitial,
    Function(bool)? setLoading,
  }) async {
    final RegExp intPattern = RegExp(r'^\d+$');

    if (isInitial) {
      if (height == null ||
          height.isEmpty ||
          weight == null ||
          weight.isEmpty ||
          selectedGender == null ||
          selectedGender.isEmpty) {
        showSnackBarMessage('invalid_data'.tr, 'all_required'.tr);
        return;
      }
    } else {
      if ((height == null || height.isEmpty) &&
          (weight == null || weight.isEmpty)) {
        showSnackBarMessage('Error!', 'no_data_update'.tr);
        return;
      }
    }

    if (height != null && height.isNotEmpty && !intPattern.hasMatch(height)) {
      showSnackBarMessage('invalid_data'.tr, 'height_number_val'.tr);
      return;
    }
    if (weight != null && weight.isNotEmpty && !intPattern.hasMatch(weight)) {
      showSnackBarMessage('invalid_data'.tr, 'weight_number_val'.tr);
      return;
    }

    setLoading?.call(true);

    late Uri fetchUrl;
    late Future<http.Response> responseFuture;

    final Map<String, dynamic> requestBody = {};

    if (isInitial) {
      requestBody['gender'] = selectedGender!;
      requestBody['height'] = int.parse(height!);
      requestBody['weight'] = int.parse(weight!);

      fetchUrl = UrlConfig.getApiUrl('user/measurements/$userId');
      responseFuture = http.post(
        fetchUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
    } else {
      if (height != null && height.isNotEmpty) {
        requestBody['height'] = int.parse(height);
      }
      if (weight != null && weight.isNotEmpty) {
        requestBody['weight'] = int.parse(weight);
      }

      fetchUrl = UrlConfig.getApiUrl('user/measurements/$userId');
      responseFuture = http.put(
        fetchUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
    }

    try {
      final http.Response response = await responseFuture;
      setLoading?.call(false);

      if ((isInitial &&
              (response.statusCode == 200 || response.statusCode == 201)) ||
          (!isInitial && response.statusCode == 200)) {
        if (isInitial) {
          showSnackBarMessage(
            'success'.tr,
            'success_update_measurments'.tr,
            success: true,
          );
          Get.off(() => PickAvailabilityPage(isUpdateAvailability: false));
        } else {
          String text;
          if (height != null &&
              height.isNotEmpty &&
              weight != null &&
              weight.isNotEmpty) {
            text = '${'height'.tr} & ${'weight'.tr}';
          } else if (height != null && height.isNotEmpty) {
            text = 'height'.tr;
          } else {
            text = 'weight'.tr;
          }
          showSnackBarMessage(
            'success'.tr,
            '$text ${'updated_successfully'.tr}',
            success: true,
          );
        }
      } else {
        String serverMessage = 'failed_update_measurments'.tr;
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          if (responseData.containsKey('message')) {
            serverMessage = responseData['message'] ?? serverMessage;
          }
        } catch (_) {}
        showSnackBarMessage('Failed!', serverMessage);
      }
    } catch (e) {
      setLoading?.call(false);
      showSnackBarMessage('server_connect_error'.tr, 'server_error_b'.tr);
    }
  }
}

void showHeightBottomSheet(BuildContext context, String UserId, String height,
    Function(String) onHeightSelected, bool updateOnSave) {
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
                Text(
                  'select_height'.tr + "(cm)",
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
                    if (updateOnSave == true) {
                      final inputDataService = InputDataService();

                      await inputDataService.submitMeasurements(
                          context: context,
                          userId: UserId,
                          height: selectedMainHeight.toString(),
                          isInitial: false);
                    }
                    await onHeightSelected("$selectedMainHeight");
                    Navigator.pop(context);
                  },
                  child: Text('save'.tr),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void showWeightBottomSheet(BuildContext context, String UserId, String weight,
    Function(String) onWeightSelected, bool updateOnSave) {
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
                Text(
                  'select_weight'.tr + "(kg)",
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
                    if (updateOnSave == true) {
                      final inputDataService = InputDataService();

                      await inputDataService.submitMeasurements(
                          context: context,
                          userId: UserId,
                          weight: selectedMainWeight.toString(),
                          isInitial: false);
                    }
                    await onWeightSelected("$selectedMainWeight");
                    Navigator.pop(context);
                  },
                  child: Text('save'.tr),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
