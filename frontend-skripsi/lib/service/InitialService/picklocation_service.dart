import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:flutter_application_1/view/InitialView/pickequipment_view.dart';

class PickLocationService {
  Future<void> continueNextPage({
    required BuildContext context,
    required String userId,
    required int selectedLocation,
    required Function(bool) setLoading,
  }) async {
    setLoading(true);
    try {
      bool isGymSelected = selectedLocation == 0;
      setLoading(false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PickEquipmentPage(
            userId: userId,
            isGymSelected: isGymSelected,
          ),
        ),
      );
    } catch (e) {
      setLoading(false);
      showSnackBarMessage(context, 'Error: Unable to connect to the server');
    }
  }
}
