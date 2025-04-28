import 'package:workout_skripsi_app/service/CommonService/export_service.dart';
import 'package:http/http.dart' as http;

//ShowSnakbarMessage
void showSnackBarMessage(String title, String message, {bool success = false}) {
  Get.snackbar(
    title,
    message,
    icon: Icon(
      success ? Icons.check_circle : Icons.error,
      color: Colors.white,
    ),
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: success ? Colors.green : Colors.red,
    colorText: Colors.white,
    margin: const EdgeInsets.all(10),
  );
}

//Generate Workout Plan
Future<http.Response> generateWorkoutPlan({required String userId}) async {
  try {
    final Uri fetchUrl = UrlConfig.getApiUrl('workout/generate/$userId');

    return await http.post(
      fetchUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}), // JSON body
    );
  } catch (e) {
    return http.Response('Network error: $e', 500);
  }
}
