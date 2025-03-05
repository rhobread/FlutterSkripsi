import 'package:flutter/material.dart';
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
      _showMessage(context, 'Error: Unable to connect to the server');
    }
  }

  void _showMessage(BuildContext context, String message,
      {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}
