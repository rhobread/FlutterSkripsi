import 'package:workout_skripsi_app/service/CommonService/export_service.dart';
import 'package:http/http.dart' as http;
import 'package:workout_skripsi_app/view/InitialView/inputData_view.dart';

class SignUpService {
  Future<void> signUp({
    required TextEditingController emailController,
    required TextEditingController usernameController,
    required TextEditingController passwordController,
    required Function(bool) setLoading,
  }) async {
    final String email = emailController.text.trim();
    final String username = usernameController.text.trim();
    final String password = passwordController.text.trim();

    if (email.isEmpty || username.isEmpty || password.isEmpty) {
      showSnackBarMessage('invalid_data'.tr, 'all_required'.tr);
      return;
    }

    setLoading(true);
    final Uri fetchUrl = UrlConfig.getApiUrl('user/register');

    try {
      final response = await http.post(
        fetchUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'name': username,
          'password': password,
        }),
      );

      setLoading(false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('data') &&
            responseData['data'].containsKey('id')) {
          String userIdEntry = responseData['data']['id'].toString();
          String userNameEntry = responseData['data']['name'].toString();

          final userController = Get.find<UserController>();
          userController.saveUser(userIdEntry, userNameEntry);

          showSnackBarMessage('success'.tr, 'signup_success'.tr, success: true);

          Get.offAll(() => InputDataPage());
        } else {
          showSnackBarMessage('failed'.tr, 'user_id_notfound'.tr);
        }
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        showSnackBarMessage(
            'failed'.tr, responseData['message'] ?? 'signup_error'.tr);
      }
    } catch (e) {
      setLoading(false);
      showSnackBarMessage('failed'.tr, 'server_connect_error'.tr);
    }
  }
}
