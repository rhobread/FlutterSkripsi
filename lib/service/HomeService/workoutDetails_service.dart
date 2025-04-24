import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:http/http.dart' as http;

class WorkoutdetailsService {
  Future<List<Map<String, dynamic>>> fetchWorkout({
    required int workoutId,
    required bool isDone,
  }) async {
    final uri = isDone ? UrlConfig.getApiUrl('workout/history/detail/$workoutId')
                       : UrlConfig.getApiUrl('workout/detail/$workoutId');

    try {
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        showSnackBarMessage(
          'Error fetching workout.',
          'Server responded with status ${response.statusCode}',
        );
        return [];
      }

      final raw = jsonDecode(response.body) as Map<String, dynamic>;

      // Unwrap the "data" key, if it exists:
      final payload = raw.containsKey('data')
          ? raw['data'] as Map<String, dynamic>
          : raw;

      final List<dynamic> list = payload['exercises'] as List<dynamic>? ?? [];

      return list.map((e) {
        final exMap = e as Map<String, dynamic>;
        final setsRaw = (exMap['sets'] as List<dynamic>).cast<Map<String, dynamic>>();

        final normalizedSets = setsRaw.map((s) {
          return {
            'set_number':  s['set_number'],
            'reps':        s['reps'],
            'weight_used': s.containsKey('weight_used') ? s['weight_used'] : null,
          };
        }).toList();

        final isWeight = normalizedSets.any((s) => s['weight_used'] != null);

        return {
          'exercise_id':         exMap['exercise_id'],
          'name':                exMap['name'] ?? '',
          'type':                exMap['type'] ?? (isWeight ? 'weight' : 'bodyweight'),
          'sets':                normalizedSets,
          'exercise_cd':         exMap['exercise_cd'] ?? null,
          'image':               exMap['image'] != null
                                  ? 'lib/assets/exercise/${exMap['image']}'
                                  : 'lib/assets/exercise/barbell-deadlift.gif',
        };
      }).toList();

    } catch (e) {
      showSnackBarMessage('Error fetching workout.', e.toString());
      return [];
    }
  }

  Future<Map<String, dynamic>?> getDescription({
    required int exerciseId,
  }) async {
    final uri = UrlConfig.getApiUrl('exercise/description/$exerciseId');

    try {
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        showSnackBarMessage(
          'Error getting description.',
          'Server responded with status ${response.statusCode}',
        );
        return null;
      }

      final raw = jsonDecode(response.body) as Map<String, dynamic>;

      final data = raw.containsKey('data') ? raw['data'] as Map<String, dynamic> : raw;

      return {
        'id':           data['id'],
        'exercise_cd':  data['exercise_cd'],
        'name':         data['name'],
        'intensity':    data['intensity'],
        'duration':     data['duration'],
        'types':        data['types'],
        'max_rep':      data['max_rep'],
        'image':        data['image'],
        'description':  data['description'] ?? '',
      };
    } catch (e) {
      showSnackBarMessage('Error getting description.', e.toString());
      return null;
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