import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:flutter_application_1/view/HomeView/main_view.dart';
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
      showSnackBarMessage('Invalid Data!','All fields are required');
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
            userController.saveUser(userId, userName);

            showSnackBarMessage('Success!','Log in successful!', success: true);

            Get.offAll(() => MainPage());
          } else {
            showSnackBarMessage('Failed!','User ID not found in response.');
          }
        } else {
          showSnackBarMessage('Failed!','Invalid response format.');
        }
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        showSnackBarMessage('Failed!',responseData['message'] ?? 'Log In failed');
      }
    } catch (e) {
      setLoading(false);
      showSnackBarMessage('Failed!','Error: Unable to connect to the server');
    }
  }
}
