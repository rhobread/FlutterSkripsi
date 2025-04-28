import 'package:workout_skripsi_app/service/CommonService/export_service.dart';
import 'package:workout_skripsi_app/view/InitialView/pickequipment_view.dart';

class PickLocationService {
  Future<void> continueNextPage({
    required String userId,
    required int selectedLocation,
    required Function(bool) setLoading,
  }) async {
    setLoading(true);
    try {
      bool isGymSelected = selectedLocation == 0;
      setLoading(false);

      Get.off(() => PickEquipmentPage(
          isGymSelected: isGymSelected, isUpdateEquipment: false));
    } catch (e) {
      setLoading(false);
      showSnackBarMessage('Failed!', 'Error: Unable to connect to the server');
    }
  }
}
