import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:flutter_application_1/view/InitialView/pickavailability_view.dart';

class PickGoalController {
  final String userId;
  bool isLoading = false;
  int selectedGoal = -1; // -1 means no selection

  final List<String> goals = [
    "Maintenance",
    "Muscle Gain / Bulking",
    "Weight Loss"
  ];

  PickGoalController(this.userId);

  void selectGoal(int index) {
    selectedGoal = index;
  }

  Future<void> continueNextPage() async {
    try {
      showSnackBarMessage('Sucess!', 'Goal Picked!', success: true);
      
      Get.off(() => PickAvailabilityPage(isUpdateAvailability: false,));

    } catch (e) {
      showSnackBarMessage('Failed!', 'Error: Unable to connect to the server');
    }
  }
}
