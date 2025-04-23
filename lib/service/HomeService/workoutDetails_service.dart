import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:http/http.dart' as http;

class WorkoutdetailsService {
  Future<List<Map<String, dynamic>>> fetchWorkout({
  required int workoutId,
  required bool isDone,
}) async {
  try {
    final uri = isDone
      ? UrlConfig.getApiUrl('workout/history/detail/$workoutId')
      : UrlConfig.getApiUrl('workout/detail/$workoutId');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      showSnackBarMessage(
        'Error fetching workout.',
        '(Status: ${response.statusCode})'
      );
      return [];
    }

    final Map<String, dynamic> raw = jsonDecode(response.body);

    final Map<String, dynamic> payload = raw.containsKey('data')
      ? Map<String, dynamic>.from(raw['data'])
      : raw;

    final List<dynamic> exercises = payload['exercises'] as List<dynamic>? ?? [];
    return exercises.map((e) {
      return {
        'workout_exercise_id': e['workout_exercise_id'],
        'name':                e['name'],
        'type':                e['type'] ?? 'unknown',
        'sets':                e['sets'] as List<dynamic>,
      };
    }).toList();
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