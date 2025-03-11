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
    final Uri url = Uri.parse('http://10.0.2.2:3005/user/measurements/$userId');

    try {
      final response = await http.put(
        url,
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
