import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/view/InitialView/picklocation_view.dart';

class PickAvailabilityService {
  Future<void> submitAvailability({
    required BuildContext context,
    required String userId,
    required Map<int, bool> selectedDays,
    required Map<int, TextEditingController> minutesControllers,
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
    final Uri url =
        Uri.parse('http://10.0.2.2:3005/user/availabilities/$userId');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'days_available': daysAvailable,
          'minutes_available': minutesAvailable,
        }),
      );

      setLoading(false);

      if (response.statusCode == 200) {
        showSnackBarMessage(context, 'Availability updated successfully!',
            success: true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PickLocationPage(userId: userId),
          ),
        );
      } else {
        showSnackBarMessage(context, 'Failed to update availability');
      }
    } catch (e) {
      setLoading(false);
      showSnackBarMessage(context, 'Error: Unable to connect to the server');
    }
  }
}
