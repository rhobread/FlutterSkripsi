import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:http/http.dart' as http;

class WorkoutdetailsService {
  Future<List<Map<String, dynamic>>> fetchWorkout({
    required int workoutId,
  }) async {
    try {
      final Uri fetchUrl = UrlConfig.getApiUrl('workout/detail/$workoutId');
      final response = await http.get(fetchUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        // Extract exercises list
        final List<dynamic> exercises = jsonData['exercises'] ?? [];

        return exercises.map((exercise) {
          return {
            'workout_exercise_id': exercise['workout_exercise_id'],
            'name': exercise['name'],
            'type': exercise['type'],
            'sets': exercise['sets'], // This is still a list of maps
          };
        }).toList();
      } else {
        showSnackBarMessage('Error fetching workout.', '(Status: ${response.statusCode})');
        return [];
      }
    } catch (e) {
      showSnackBarMessage('Error fetching workout.', '$e');
      return [];
    }
  }

  Future<bool> finishWorkout({
    required int userId,
    required int workoutId,
    required List<Map<String, dynamic>> exercises,
  }) async {
    final Uri url = UrlConfig.getApiUrl('workout/create');
    final body = {
      "user_id": userId,
      "workout_id": workoutId,
      // ISO8601 UTC timestamp
      "date": DateTime.now().toUtc().toIso8601String(),
      "exercises": exercises.map((item) {
        final ex = item['exercise'] as Map<String, dynamic>;
        final sets = item['sets'] as List<Map<String, dynamic>>;
        return {
          "workout_exercise_id": ex['workout_exercise_id'],
          "name": ex['name'],
          "sets": sets.map((s) {
            final m = {
              "set_number": s['set_number'],
              "reps": s['reps'],
            };
            if (s.containsKey('weight_used') && s['weight_used'] != null) {
              m["weight_used"] = s['weight_used'];
            }
            return m;
          }).toList(),
        };
      }).toList(),
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        showSnackBarMessage(
          'Error finishing workout',
          'Server responded ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      showSnackBarMessage('Error finishing workout', e.toString());
      return false;
    }
  }
}