import 'package:workout_skripsi_app/service/CommonService/export_service.dart';
import 'package:http/http.dart' as http;

class ProfileDetailsService {
  Future<Map<String, dynamic>?> getUserDetails({
    required String userId,
  }) async {
    try {
      final Uri fetchUrl = UrlConfig.getApiUrl('user/$userId');
      final response = await http.get(fetchUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        var data = jsonData['data'];
        return data;
      } else {
        showSnackBarMessage('error_fetching_userDetails'.tr,
            '(Status: ${response.statusCode})');
        return null;
      }
    } catch (e) {
      showSnackBarMessage('error_fetching_userDetails'.tr, ' $e');
      return null;
    }
  }
}
