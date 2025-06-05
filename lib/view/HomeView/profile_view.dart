import 'package:workout_skripsi_app/service/CommonService/export_service.dart';
import 'package:workout_skripsi_app/view/HomeView/profileDetails_view.dart';
import 'package:workout_skripsi_app/view/InitialView/login_view.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});
  final userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: buildCustomAppBar(title: 'profile'.tr),
      ),
      body: Column(
        children: [
          // Backup & Restore Section
          buildContainer(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            child: ListTile(
              title: const Text("Hello",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text(userController.userName.value,
                  style: const TextStyle(color: Colors.grey)),
            ),
          ),

          // Settings Section
          buildContainer(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                buildSettingsTile(
                  context,
                  Icons.person,
                  'my_profile'.tr,
                  Colors.blue,
                  onTap: () => Get.to(() => const ProfileDetailsPage()),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Log Out Section
          buildContainer(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: buildSettingsTile(
              context,
              Icons.logout,
              'log_out'.tr,
              Colors.red,
              onTap: () => _showLogoutConfirmation(context),
            ),
          ),

          const Spacer(),

          // Version Info
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    Get.defaultDialog(
      title: 'confirm_logout'.tr,
      middleText: 'logout_confirmation'.tr,
      textCancel: 'no'.tr,
      textConfirm: 'yes'.tr,
      confirmTextColor: Colors.white,
      onConfirm: () async {
        final userController = Get.find<UserController>();
        await userController.clearUserId();
        Get.offAll(() => const LoginPage());
      },
    );
  }
}
