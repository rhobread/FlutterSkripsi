import 'package:flutter_application_1/service/CommonService/export_service.dart';

class UserController extends GetxController {
  var userId = "".obs; // 🔄 Reactive userId
  var userName = "".obs;

  // 1️ Load userId on app startup
  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId.value = prefs.getString('userId') ?? "";
    userName.value = prefs.getString('userName') ?? "";
  }

  // 2️ Save userId after login/signup
  Future<void> saveUser(String id, String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', id);
    await prefs.setString('userName', name);
    userId.value = id;
    userName.value = name;
  }

  // 3️Clear userId on logout
  Future<void> clearUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    userId.value = "";
    userName.value = "";
  }
}
