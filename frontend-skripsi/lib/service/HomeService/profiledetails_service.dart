import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:http/http.dart' as http;

class ProfileDetailsService {
  Future<Map<String, dynamic>?> getUserDetails({
    required BuildContext context,
    required String userId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3005/user/$userId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        var data = jsonData['data'];
        return data;
      } else {
        showSnackBarMessage(context,
            'Error fetching user details. (Status: ${response.statusCode})');
        return null;
      }
    } catch (e) {
      showSnackBarMessage(context, 'Error fetching user details: $e');
      return null;
    }
  }
}
