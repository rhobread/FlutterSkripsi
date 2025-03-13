import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/view/InitialView/inputdata_view.dart';

class SignUpService {
  Future<void> signUp({
    required BuildContext context,
    required TextEditingController emailController,
    required TextEditingController usernameController,
    required TextEditingController passwordController,
    required Function(bool) setLoading,
  }) async {
    final String email = emailController.text.trim();
    final String username = usernameController.text.trim();
    final String password = passwordController.text.trim();

    if (email.isEmpty || username.isEmpty || password.isEmpty) {
      showSnackBarMessage(context, 'All fields are required');
      return;
    }

    setLoading(true);
    final Uri url = Uri.parse('http://10.0.2.2:3005/user/register');

    try {
      final response = await http.post(
        url,
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
          String userId = responseData['data']['id'].toString();

          final userController = Get.find<UserController>();
          userController.saveUserId(userId);

          showSnackBarMessage(context, 'Sign up successful!', success: true);

          Get.offAll(() => InputDataPage());
        } else {
          showSnackBarMessage(context, 'User ID not found in response.');
        }
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        showSnackBarMessage(
            context, responseData['message'] ?? 'Sign up failed');
      }
    } catch (e) {
      setLoading(false);
      showSnackBarMessage(context, 'Error: Unable to connect to the server');
    }
  }
}
