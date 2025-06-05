import 'package:workout_skripsi_app/service/CommonService/export_service.dart';
import 'package:http/http.dart' as http;

class WorkoutdetailsService {
  Future<List<Map<String, dynamic>>> fetchWorkout({
    required int workoutId,
    required bool isDone,
  }) async {
    final uri = isDone
        ? UrlConfig.getApiUrl('workout/history/detail/$workoutId')
        : UrlConfig.getApiUrl('workout/detail/$workoutId');

    try {
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        showSnackBarMessage(
          'error_fetching_workouts'.tr,
          'server_status_respond'.tr + ' ${response.statusCode}',
        );
        return [];
      }

      final raw = jsonDecode(response.body) as Map<String, dynamic>;

      // Unwrap the "data" key, if it exists:
      final payload =
          raw.containsKey('data') ? raw['data'] as Map<String, dynamic> : raw;

      final List<dynamic> list = payload['exercises'] as List<dynamic>? ?? [];

      return list.map((e) {
        final exMap = e as Map<String, dynamic>;
        final setsRaw =
            (exMap['sets'] as List<dynamic>).cast<Map<String, dynamic>>();

        final normalizedSets = setsRaw.map((s) {
          return {
            'set_number': s['set_number'],
            'reps': s['reps'],
            'weight_used':
                s.containsKey('weight_used') ? s['weight_used'] : null,
          };
        }).toList();

        final isWeight = normalizedSets.any((s) => s['weight_used'] != null);

        return {
          'workout_exercise_id': exMap['workout_exercise_id'],
          'exercise_id': exMap['exercise_id'],
          'name': exMap['name'] ?? '',
          'type': exMap['type'] ?? (isWeight ? 'weight' : 'bodyweight'),
          'sets': normalizedSets,
          'exercise_cd': exMap['exercise_cd'] ?? null,
          'image': exMap['image'] != null
              ? 'lib/assets/exercise/${exMap['image']}'
              : 'lib/assets/exercise/barbell-deadlift.gif',
        };
      }).toList();
    } catch (e) {
      showSnackBarMessage('error_fetching_workouts'.tr + ' ', e.toString());
      return [];
    }
  }

//   Future<Map<String, dynamic>?> getDesscriptionV2({
//   required int exerciseId,
// }) async {
//   // 1) Pick up your two-letter code and map to eng/ind
//   final locale = Get.locale ?? Get.fallbackLocale ?? const Locale('en','US');
//   final langParam = locale.languageCode == 'id' ? 'ind' : 'eng';

//   // 2) Build the full URL (as a String) including the ?lang=…
//   final baseUrl = UrlConfig.getApiUrl('exercise/description/$exerciseId');
//   final urlWithLang = '$baseUrl?lang=$langParam';

//   try {
//     // 3) Parse once here, then pass the Uri to http.get
//     final uri = Uri.parse(urlWithLang);
//     final response = await http.get(uri);

//     if (response.statusCode != 200) {
//       showSnackBarMessage(
//         'Error getting description.',
//         'Server responded with status ${response.statusCode}',
//       );
//       return null;
//     }

//     final raw = jsonDecode(response.body) as Map<String, dynamic>;
//     final data = raw['data'] as Map<String, dynamic>;

//     final typesRaw = data['types'];
//     final List<String> typesList = typesRaw is List
//         ? typesRaw.cast<String>()
//         : (typesRaw is String ? [typesRaw] : []);

//     return {
//       'id': data['id'],
//       'exercise_cd': data['exercise_cd'],
//       'name': data['name'],
//       'intensity': data['intensity'],
//       'duration': data['duration'],
//       'types': typesList,
//       'max_rep': data['max_rep'],
//       'image': data['image'] != null
//           ? 'lib/assets/exercise/${data['image']}'
//           : 'lib/assets/exercise/barbell-deadlift.gif',
//       'description': (data['description'] as String?)?.trim() ?? '',
//     };
//   } catch (e) {
//     showSnackBarMessage('Error getting description.', e.toString());
//     return null;
//   }
// }

  Future<Map<String, dynamic>?> getDescription({
    required int exerciseId,
  }) async {
    final uri = UrlConfig.getApiUrl('exercise/description/$exerciseId');

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        showSnackBarMessage(
          'error_fetching_description'.tr,
          'server_status_respond'.tr + ' ${response.statusCode}',
        );
        return null;
      }

      final decoded = jsonDecode(response.body);
      // If the root is not a Map, bail out with null
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final dataRaw = decoded['data'];
      // If data is not a Map, return a map of safe defaults
      if (dataRaw is! Map<String, dynamic>) {
        return {
          'id': 0,
          'exercise_cd': '',
          'name': '',
          'intensity': 0,
          'duration': 0,
          'types': <String>[],
          'max_rep': 0,
          'image': 'lib/assets/exercise/barbell-deadlift.gif',
          'description': '',
        };
      }

      final data = dataRaw;

      // 1) Parse id, intensity, duration, max_rep as ints (or 0 if null/invalid)
      final id = int.tryParse(data['id']?.toString() ?? '') ?? 0;
      final intensity = int.tryParse(data['intensity']?.toString() ?? '') ?? 0;
      final duration = int.tryParse(data['duration']?.toString() ?? '') ?? 0;
      final maxRep = int.tryParse(data['max_rep']?.toString() ?? '') ?? 0;

      // 2) exercise_cd, name → default to empty string if null
      final exerciseCd = (data['exercise_cd'] as String?) ?? '';
      final name = (data['name'] as String?) ?? '';

      // 3) Build typesList safely
      final typesRaw = data['types'];
      final List<String> typesList = <String>[];
      if (typesRaw is List) {
        for (final t in typesRaw) {
          if (t is String) {
            final trimmed = t.trim();
            if (trimmed.isNotEmpty) typesList.add(trimmed);
          } else if (t != null) {
            // in case the backend sends numbers or other, coerce to string
            final s = t.toString().trim();
            if (s.isNotEmpty) typesList.add(s);
          }
        }
      } else if (typesRaw is String) {
        final trimmed = typesRaw.trim();
        if (trimmed.isNotEmpty) typesList.add(trimmed);
      }
      // 4) Compute imagePath: if data['image'] is null, use default gif
      final imagePath = (data['image'] as String?) != null
          ? 'lib/assets/exercise/${(data['image'] as String).trim()}'
          : 'lib/assets/exercise/barbell-deadlift.gif';

      // 5) description → default to empty string if null
      final description = (data['description'] as String?)?.trim() ?? '';

      return {
        'id': id,
        'exercise_cd': exerciseCd,
        'name': name,
        'intensity': intensity,
        'duration': duration,
        'types': typesList,
        'max_rep': maxRep,
        'image': imagePath,
        'description': description,
      };
    } catch (e) {
      showSnackBarMessage('error_fetching_description'.tr + " ", e.toString());
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getExerciseRecords({
    required int userId,
    required String exerciseCd,
  }) async {
    try {
      final uri = UrlConfig.getApiUrl('workout/exercise-history').replace(
        queryParameters: {
          'user_id': userId.toString(),
          'exercise_cd': exerciseCd,
        },
      );

      final response = await http.get(uri);
      if (response.statusCode != 200) {
        showSnackBarMessage(
          'error_fetching_records'.tr,
          '(HTTP ${response.statusCode})',
        );
        return [];
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return [];
      }

      // If statusCode isn’t 200, bail out
      final statusCode = decoded['statusCode'];
      if (statusCode is! int || statusCode != 200) {
        showSnackBarMessage(
          'error_fetching_records'.tr,
          'API error: ${decoded['message'] ?? 'Unknown'}',
        );
        return [];
      }

      // rawList might be null or not a List; default to empty
      final rawList = decoded['data'] as List<dynamic>? ?? <dynamic>[];
      final List<Map<String, dynamic>> safeList = <Map<String, dynamic>>[];

      for (final e in rawList) {
        // If e isn’t a map, skip it
        if (e is! Map<String, dynamic>) continue;
        final item = <String, dynamic>{}..addAll(e);

        // 1) Safely parse reps → List<int>
        final repsRaw = item['reps'] as List<dynamic>?;
        final List<int> reps = <int>[];
        if (repsRaw != null) {
          for (final v in repsRaw) {
            if (v is num) {
              reps.add(v.toInt());
            } else if (v != null) {
              reps.add(int.tryParse(v.toString()) ?? 0);
            } else {
              reps.add(0);
            }
          }
        }

        // 2) Safely parse weights → List<int>
        final weightsRaw = item['weight_used'] as List<dynamic>?;
        final List<int> weights = <int>[];
        if (weightsRaw != null) {
          for (final v in weightsRaw) {
            if (v is num) {
              weights.add(v.toInt());
            } else if (v != null) {
              weights.add(int.tryParse(v.toString()) ?? 0);
            } else {
              weights.add(0);
            }
          }
        }

        // 3) sets_done: if it’s an int, use it; otherwise default to reps.length
        final setsDone = (item['sets_done'] is int)
            ? (item['sets_done'] as int)
            : reps.length;

        // 4) date and exercise_name default to empty string if null
        final dateStr = (item['date'] as String?) ?? '';
        final exerciseName = (item['exercise_name'] as String?) ?? '';

        // 5) totalDuration: default to 0 if null or non-int
        final totalDuration =
            int.tryParse(item['totalDuration']?.toString() ?? '') ?? 0;

        safeList.add({
          'date': dateStr,
          'exercise_name': exerciseName,
          'sets_done': setsDone,
          'reps': reps,
          'totalDuration': totalDuration,
          'weight_used': weights,
        });
      }

      return safeList;
    } catch (e) {
      showSnackBarMessage('error_fetching_records'.tr, ' $e');
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
              "set_number": s['set_number'] ?? 0,
              "reps": (s['reps'] is int)
                  ? s['reps']
                  : int.tryParse('${s['reps']}') ?? 0,
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
          'error_finishing_workout'.tr,
          ' server_status_respond'.tr + ' ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      showSnackBarMessage('error_finishing_workout'.tr + ' ', e.toString());
      return false;
    }
  }
}
