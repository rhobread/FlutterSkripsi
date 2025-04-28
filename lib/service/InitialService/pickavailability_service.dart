import 'package:workout_skripsi_app/service/CommonService/export_service.dart';
import 'package:http/http.dart' as http;
import 'package:workout_skripsi_app/view/InitialView/picklocation_view.dart';

class PickAvailabilityService {
  Future<List<Map<String, dynamic>>> getUserAvailability(
      {required String userId}) async {
    try {
      final Uri fetchUrl = UrlConfig.getApiUrl('user/availability/$userId');
      final response = await http.get(fetchUrl);

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = jsonBody['data'];

        List<Map<String, dynamic>> availabilityList = data.map((item) {
          return {
            'day': item['day'],
            'minutes': item['minutes'],
          };
        }).toList();

        return availabilityList;
      } else {
        showSnackBarMessage('Error!', 'error_getting_user_availability'.tr);
        return [];
      }
    } catch (e) {
      showSnackBarMessage('Error!', 'error_getting_user_availability' + ' $e');
      return [];
    }
  }

  Future<void> submitAvailability({
    required String userId,
    required Map<int, bool> selectedDays,
    required Map<int, TextEditingController> minutesControllers,
    required bool isUpdateAvailability,
    required Function(bool) setLoading,
  }) async {
    List<int> daysAvailable = [];
    List<int> minutesAvailable = [];
    for (int i = 0; i < 7; i++) {
      if (selectedDays[i] == true) {
        daysAvailable.add(i);
        minutesAvailable.add(int.tryParse(minutesControllers[i]!.text) ?? 0);
      }
    }
    setLoading(true);
    final Uri fetchUrl = UrlConfig.getApiUrl('user/availabilities/$userId');

    try {
      final response = await http.put(
        fetchUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'days_available': daysAvailable,
          'minutes_available': minutesAvailable,
        }),
      );

      setLoading(false);

      if (response.statusCode == 200) {
        showSnackBarMessage('success'.tr, 'success_update_availability'.tr,
            success: true);

        if (isUpdateAvailability) {
          Get.back();
        } else {
          Get.off(() => PickLocationPage());
        }
      } else {
        showSnackBarMessage('failed'.tr, 'failed_update_availability'.tr);
      }
    } catch (e) {
      setLoading(false);
      showSnackBarMessage('Error!', 'server_connect_error'.tr);
    }
  }
}
