import 'package:flutter_application_1/service/CommonService/export_service.dart';

class UserController extends GetxController {
  var userId = "".obs; // 🔄 Reactive userId

  // 1️ Load userId on app startup
  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId.value = prefs.getString('userId') ?? "";
  }

  // 2️ Save userId after login/signup
  Future<void> saveUserId(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', id);
    userId.value = id;
  }

  // 3️Clear userId on logout
  Future<void> clearUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    userId.value = "";
  }
}
