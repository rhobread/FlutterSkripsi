import 'package:flutter_application_1/service/CommonService/export_service.dart';
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
        showSnackBarMessage('Error fetching user details.', '(Status: ${response.statusCode})');
        return null;
      }
    } catch (e) {
      showSnackBarMessage('Error fetching user details.', '$e');
      return null;
    }
  }
}
