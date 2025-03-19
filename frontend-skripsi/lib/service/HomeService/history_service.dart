import 'package:http/http.dart' as http;
import 'package:flutter_application_1/service/CommonService/export_service.dart';

class HistoryService {
  Future<List<Map<String, dynamic>>> getHistory({
    required BuildContext context,
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
          return List<Map<String, dynamic>>.from(data);
        } else {
          showSnackBarMessage(context, 'Error: ${jsonData['message']}');
          return [];
        }
      } else {
        showSnackBarMessage(
            context, 'Error fetching history. (Status: ${response.statusCode})');
        return [];
      }
    } catch (e) {
      showSnackBarMessage(context, 'Error fetching history: $e');
      return [];
    }
  }
}
