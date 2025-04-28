import 'package:workout_skripsi_app/service/CommonService/export_service.dart';
import 'package:http/http.dart' as http;

class HomeService {
  Future<List<Map<String, dynamic>>> fetchWorkouts({
    required String userId,
  }) async {
    try {
      final Uri fetchUrl = UrlConfig.getApiUrl('workout/user/$userId');
      final response = await http.get(fetchUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> workouts = jsonData['data']; // Extract list

        return workouts.map((workout) {
          return {
            'workout_id': workout['workout_id'],
            'date': workout['date'],
            'status': workout['status'],
            'totalWorkoutDuration': workout['totalWorkoutDuration']
          };
        }).toList();
      } else {
        showSnackBarMessage(
            'Error fetching workouts. ', '(Status: ${response.statusCode})');
        return [];
      }
    } catch (e) {
      showSnackBarMessage('Error fetching workouts. ', '$e');
      return [];
    }
  }
}
