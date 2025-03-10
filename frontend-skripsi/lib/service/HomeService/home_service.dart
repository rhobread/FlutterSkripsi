import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:http/http.dart' as http;

class HomeService {
  Future<List<Map<String, dynamic>>> fetchWorkouts({
    required BuildContext context,
    required String userId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3005/workout/user/$userId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> workouts = jsonData['workouts']; // Extract list

        return workouts.map((workout) {
          return {
            'date': workout['date'],
            'exercises': List<Map<String, dynamic>>.from(workout['exercises']),
          };
        }).toList();
      } else {
        showSnackBarMessage(context,
            'Error fetching workouts. (Status: ${response.statusCode})');
        return [];
      }
    } catch (e) {
      showSnackBarMessage(context, 'Error fetching workouts: $e');
      return [];
    }
  }
}
