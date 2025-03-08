import 'dart:convert';
import 'package:flutter_application_1/service/CommonService/common_service.dart';
import 'package:flutter_application_1/view/HomeView/home_view.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class LoginService {
  Future<void> Login({
    required BuildContext context,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required Function(bool) setLoading,
  }) async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showSnackBarMessage(context, 'All fields are required');
      return;
    }

    setLoading(true);
    final Uri url = Uri.parse('http://10.0.2.2:3005/user/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      setLoading(false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        final List<dynamic>? responseData = jsonResponse.values.toList();

        if (responseData != null && responseData.isNotEmpty) {
          var userIdEntry = responseData[0];

          if (userIdEntry != null) {
            String userId = userIdEntry.toString();
            showSnackBarMessage(context, 'Log in successful!', success: true);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage(userId: userId)),
            );
          } else {
            showSnackBarMessage(context, 'User ID not found in response.');
          }
        } else {
          showSnackBarMessage(context, 'Invalid response format.');
        }
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        showSnackBarMessage(
            context, responseData['message'] ?? 'Log In failed');
      }
    } catch (e) {
      setLoading(false);
      showSnackBarMessage(context, 'Error: Unable to connect to the server');
    }
  }
}
