import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:flutter_application_1/view/HomeView/main_view.dart';
// import 'package:flutter_application_1/view/HomeView/profile_view.dart';
// import 'package:flutter_application_1/view/InitialView/inputdata_view.dart';
// import 'package:flutter_application_1/view/InitialView/login_view.dart';
// import 'package:flutter_application_1/view/InitialView/pickequipment_view.dart';
// import 'package:flutter_application_1/view/InitialView/pickgoal_view.dart';
// import 'package:flutter_application_1/view/InitialView/picklocation_view.dart';
import 'package:flutter_application_1/view/InitialView/signup_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final userController = Get.put(UserController()); // Register globally
  await userController.loadUserId(); // Load userId before app starts
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: GetBuilder<UserController>(
        builder: (userController) {
          return userController.userId.isNotEmpty ? MainPage() : SignUpPage();
          //zz return PickEquipmentPage( isGymSelected: true,);
          // return PickLocationPage();
        },
      ),
    );
  }
}
