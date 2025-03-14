import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:http/http.dart' as http;

//ShowSnakbarMessage
void showSnackBarMessage(BuildContext context, String message,
    {bool success = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: success ? Colors.green : Colors.red,
    ),
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
