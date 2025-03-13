import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:flutter_application_1/view/HomeView/profiledetails_view.dart';
import 'package:flutter_application_1/view/InitialView/login_view.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("ME",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Backup & Restore Section
          buildContainer(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            child: const ListTile(
              title: Text("Hello",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text("GayBoy69", style: TextStyle(color: Colors.grey)),
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
                  "My Profile",
                  Colors.blue,
                  onTap: () => Get.to(() => const ProfileDetailsPage(
                        userId: "12",
                      )),
                ),
                buildSettingsTile(
                  context,
                  Icons.history,
                  "History",
                  Colors.pink,
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
              "Log Out",
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
      title: "Confirm Logout",
      middleText: "Are you sure you want to log out?",
      textCancel: "No",
      textConfirm: "Yes",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await UserController().clearUserId();
        Get.off(() => const LoginPage());
      },
    );
  }
}
