import 'package:http/http.dart' as http;
import 'package:workout_skripsi_app/service/CommonService/export_service.dart';

class HistoryService {
  Future<List<Map<String, dynamic>>> getExerciseHistory({
    required String userId,
    required String startMonth,
    required String endMonth,
  }) async {
    try {
      final Uri baseUrl = UrlConfig.getApiUrl('workout/exercise-history/all');
      final Uri uriWithParams = baseUrl.replace(queryParameters: {
        'user_id': userId,
        'start_date': startMonth,
        'end_date': endMonth,
      });

      final response = await http.get(uriWithParams);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        if (jsonData['statusCode'] == 200) {
          final List<dynamic> data = jsonData['data'];

          return data.map<Map<String, dynamic>>((exercise) {
            return {
              'exercise_id':
                  exercise['exercise_id'], //need to update to id when api retrn
              'exercise_cd': exercise['exercise_cd'],
              'exercise_name': exercise['exercise_name'],
              'exercise_image': exercise['exercise_image'] != null
                  ? 'lib/assets/exercise/${exercise['exercise_image']}'
                  : 'lib/assets/exercise/barbell-deadlift.gif',
            };
          }).toList();
        } else {
          showSnackBarMessage(
              'error_fetching_history'.tr, 'Error: ${jsonData['message']}');
          return [];
        }
      } else {
        showSnackBarMessage(
            'error_fetching_history'.tr, '(Status: ${response.statusCode})');
        return [];
      }
    } catch (e) {
      showSnackBarMessage('error_fetching_history'.tr + ' : ', '$e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCompletedWorkouts({
    required String userId,
  }) async {
    try {
      final Uri baseUrl = UrlConfig.getApiUrl('workout/progress/get/$userId');

      final response = await http.get(baseUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        if (jsonData['statusCode'] == 200) {
          final List<dynamic> data = jsonData['data'];

          // Extract only workout_id and date
          return data.map<Map<String, dynamic>>((workout) {
            return {
              'workout_id': workout['workout_id'],
              'date': workout['date'],
            };
          }).toList();
        } else {
          showSnackBarMessage(
              'error_fetching_workouts'.tr, 'Error: ${jsonData['message']}');
          return [];
        }
      } else {
        showSnackBarMessage(
            'error_fetching_workouts'.tr, '(Status: ${response.statusCode})');
        return [];
      }
    } catch (e) {
      showSnackBarMessage('error_fetching_workouts'.tr + ' : ', '$e');
      return [];
    }
  }
}
