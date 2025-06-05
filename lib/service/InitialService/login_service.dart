import 'package:workout_skripsi_app/service/CommonService/export_service.dart';
import 'package:workout_skripsi_app/view/HomeView/main_view.dart';
import 'package:http/http.dart' as http;

class LoginService {
  Future<void> Login({
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required Function(bool) setLoading,
  }) async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showSnackBarMessage('invalid_data'.tr, 'all_required'.tr);
      return;
    }

    setLoading(true);
    final Uri fetchUrl = UrlConfig.getApiUrl('user/login');

    try {
      final response = await http.post(
        fetchUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      setLoading(false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> responseData = jsonResponse.values.toList();

        if (responseData.isNotEmpty) {
          var userIdEntry = responseData[2]["id"];
          var userNameEntry = responseData[2]["name"];

          if (userIdEntry != null) {
            String userId = userIdEntry.toString();
            String userName =
                (userNameEntry != null) ? userNameEntry.toString() : "";

            final userController = Get.find<UserController>();
            await userController.saveUser(userId, userName);

            showSnackBarMessage('success'.tr, 'login_success'.tr,
                success: true);

            Get.offAll(() => MainPage());
          } else {
            showSnackBarMessage('failed'.tr, 'user_id_notfound'.tr);
          }
        } else {
          showSnackBarMessage('failed'.tr, 'invalid_data'.tr);
        }
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        showSnackBarMessage(
            'failed'.tr, responseData['message'] ?? 'login_fail'.tr);
      }
    } catch (e) {
      setLoading(false);
      showSnackBarMessage('failed'.tr, 'server_error_b'.tr);
    }
  }
}
