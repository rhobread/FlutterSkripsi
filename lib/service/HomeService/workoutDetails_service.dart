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
          'workout_exercise_id': exMap['workout_exercise_id'],
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
      final data = raw['data'] as Map<String, dynamic>;

      final typesRaw = data['types'];
      final List<String> typesList = typesRaw is List
          ? typesRaw.cast<String>()
          : (typesRaw is String ? [typesRaw] : []);

      return {
        'id': data['id'],
        'exercise_cd': data['exercise_cd'],
        'name': data['name'],
        'intensity': data['intensity'],
        'duration': data['duration'],
        'types': typesList,
        'max_rep': data['max_rep'],
        'image': data['image'] != null
            ? 'lib/assets/exercise/${data['image']}'
            : 'lib/assets/exercise/barbell-deadlift.gif',
        'description': (data['description'] as String?)?.trim() ?? '',
      };
    } catch (e) {
      showSnackBarMessage('Error getting description.', e.toString());
      return null;
    }
  }

 Future<List<Map<String, dynamic>>> getExerciseRecords({
  required int userId,
  required String exerciseCd,
}) async {
  try {
    // Build the URL with string parameters
    final uri = UrlConfig
        .getApiUrl('workout/exercise-history')
        .replace(queryParameters: {
      'user_id': userId.toString(),
      'exercise_cd': exerciseCd,
    });

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      showSnackBarMessage(
        'Error fetching records.',
        '(HTTP ${response.statusCode})',
      );
      return [];
    }

    final Map<String, dynamic> jsonData = jsonDecode(response.body);
    if (jsonData['statusCode'] != 200) {
      showSnackBarMessage(
        'Error fetching records.',
        'API error: ${jsonData['message']}',
      );
      return [];
    }

    final List<dynamic> rawList = jsonData['data'] as List<dynamic>? ?? [];
    return rawList.map((e) {
      final item = Map<String, dynamic>.from(e);

      // Safely parse reps & weights (may be null for bodyweight)
      final reps = (item['reps'] as List<dynamic>?)
            ?.map((v) => (v as num).toInt())
            .toList() ?? <int>[];
      final weights = (item['weight_used'] as List<dynamic>?)
            ?.map((v) => (v as num).toInt())
            .toList() ?? <int>[];

      // If sets_done is missing, fall back to number of reps
      final setsDone = (item['sets_done'] is int)
          ? item['sets_done'] as int
          : reps.length;

      return {
        'date':          item['date']           as String? ?? '',
        'exercise_name': item['exercise_name']  as String? ?? '',
        'sets_done':     setsDone,
        'reps':          reps,
        'totalDuration': item['totalDuration']  as int?    ?? 0,
        'weight_used':   weights,
      };
    }).toList();
  } catch (e) {
    showSnackBarMessage('Error fetching records:', '$e');
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