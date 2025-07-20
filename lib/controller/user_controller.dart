// import 'package:workout_skripsi_app/service/CommonService/export_service.dart';

// class UserController extends GetxController {
//   var userId = "".obs; // 🔄 Reactive userId
//   var userName = "".obs;

//   // 1️ Load userId on app startup
//   Future<void> loadUserId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     userId.value = prefs.getString('userId') ?? "";
//     userName.value = prefs.getString('userName') ?? "";
//   }

//   // 2️ Save userId after login/signup
//   Future<void> saveUser(String id, String name) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('userId', id);
//     await prefs.setString('userName', name);
//     userId.value = id;
//     userName.value = name;
//   }

//   // 3️ Clear userId on logout
//   Future<void> clearUserId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     await Future.wait([
//       prefs.remove('userId'),
//       prefs.remove('userName'),
//     ]);

//     userId.value = "";
//     userName.value = "";
//   }
// }

import 'package:workout_skripsi_app/service/CommonService/export_service.dart';

class UserController extends GetxController {
  var userId = "".obs; // 🔄 Reactive userId
  var userName = "".obs;
  var measurementsInputted = false.obs;
  var availabilityInputted = false.obs;
  var equipmentInputted = false.obs;

  // 1️ Load userId on app startup
  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId.value = prefs.getString('userId') ?? "";
    userName.value = prefs.getString('userName') ?? "";
    measurementsInputted.value = prefs.getBool('measurementsInputted') ?? false;
    availabilityInputted.value = prefs.getBool('availabilityInputted') ?? false;
    equipmentInputted.value = prefs.getBool('equipmentInputted') ?? false;
  }

  // 2️ Save userId after login/signup
  Future<void> saveUser(String id, String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', id);
    await prefs.setString('userName', name);
    userId.value = id;
    userName.value = name;
  }

  Future<void> saveUserInputtedWeight() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('measurementsInputted', true);
    measurementsInputted.value = true;
  }

  Future<void> saveUserAvailability() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('availabilityInputted', true);
    availabilityInputted.value = true;
  }

  Future<void> saveUserEquipment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('equipmentInputted', true);
    equipmentInputted.value = true;
  }

  // 3️ Clear userId on logout
  Future<void> clearUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.remove('userId'),
      prefs.remove('userName'),
      prefs.remove('measurementsInputted'),
      prefs.remove('availabilityInputted'),
      
    ]);

    userId.value = "";
    userName.value = "";
    measurementsInputted.value = false;
    availabilityInputted.value = false;
  }
}
