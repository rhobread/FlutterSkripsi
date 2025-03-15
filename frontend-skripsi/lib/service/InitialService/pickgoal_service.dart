import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:flutter_application_1/view/InitialView/pickavailability_view.dart';

class PickGoalController {
  final BuildContext context;
  final String userId;
  bool isLoading = false;
  int selectedGoal = -1; // -1 means no selection

  final List<String> goals = [
    "Maintenance",
    "Muscle Gain / Bulking",
    "Weight Loss"
  ];

  PickGoalController(this.userId, this.context);

  void selectGoal(int index) {
    selectedGoal = index;
  }

  Future<void> continueNextPage() async {
    try {
      _showMessage('Goal Picked!', success: true);
      
      Get.off(() => PickAvailabilityPage(isUpdateAvailability: false,));

    } catch (e) {
      _showMessage('Error: Unable to connect to the server');
    }
  }

  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}
