import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:workout_skripsi_app/service/CommonService/export_service.dart';
import 'package:workout_skripsi_app/view/HomeView/main_view.dart';
import 'package:workout_skripsi_app/view/InitialView/inputData_view.dart';
import 'package:workout_skripsi_app/view/InitialView/pickAvailability_view.dart';
import 'package:workout_skripsi_app/view/InitialView/pickLocation_view.dart';
import 'package:workout_skripsi_app/view/InitialView/signup_view.dart';
import 'package:workout_skripsi_app/localization/translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting();

  final userController = Get.put(UserController());
  await userController.loadUserId();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: MyTranslations(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('id', 'ID'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // home: GetBuilder<UserController>(
      //   builder: (userController) {
      //     return userController.userId.isNotEmpty
      //         ? const MainPage()
      //         : const SignUpPage();
      //   },
      // ),
      home: GetBuilder<UserController>(
        builder: (userController) {
          if (userController.userId.isEmpty) {
            return const SignUpPage();
          }

          if (userController.equipmentInputted.value) {
            return const MainPage();
          }

          if (!userController.measurementsInputted.value) {
            return const InputDataPage();
          }

          if (!userController.availabilityInputted.value) {
            return const PickAvailabilityPage(isUpdateAvailability: false);
          }

          if (!userController.equipmentInputted.value) {
            return const PickLocationPage();
          }

          return const MainPage(); 
        },
      ),
    );
  }
}
