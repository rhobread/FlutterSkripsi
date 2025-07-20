import 'package:workout_skripsi_app/service/CommonService/export_service.dart';
import 'package:workout_skripsi_app/view/HomeView/main_view.dart';
import 'package:http/http.dart' as http;

class PickEquipmentService {
  Future<List<Map<String, dynamic>>> fetchEquipments({
    required bool isGymSelected,
  }) async {
    try {
      final Uri fetchUrl = UrlConfig.getApiUrl('workout/equipments');
      final response = await http.get(fetchUrl);

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = jsonBody['data'];

        List<Map<String, dynamic>> equipmentList = data.map((item) {
          return {
            'id': item['id'],
            'name': item['name'],
            'image': 'lib/assets/equipments/${item['image']}',
          };
        }).toList();

        return equipmentList;
      } else {
        showSnackBarMessage(
            'failed'.tr, 'error_get_equipment'.tr + ' ${response.statusCode})');
        return [];
      }
    } catch (e) {
      showSnackBarMessage('failed'.tr, 'error_get_equipment'.tr + ' $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUserEquipments(
      {required String userId}) async {
    try {
      final Uri fetchUrl = UrlConfig.getApiUrl('user/equipments/$userId');
      final response = await http.get(fetchUrl);

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = jsonBody['data'];

        List<Map<String, dynamic>> equipmentList = data.map((item) {
          return {
            'id': item['equipment_id'],
          };
        }).toList();

        return equipmentList;
      } else {
        showSnackBarMessage(
            'failed'.tr, 'error_get_equipment'.tr + ' ${response.statusCode})');
        return [];
      }
    } catch (e) {
      showSnackBarMessage('failed'.tr, 'error_get_equipment' + ' $e');
      return [];
    }
  }

  Future<void> submitEquipmentSelection({
    required String userId,
    required Set<int> selectedEquipment,
    required bool isUpdateEquipment,
    required Function(bool) setLoading,
  }) async {
    setLoading(true);
    try {
      final Uri fetchUrl = UrlConfig.getApiUrl('user/equipments/$userId');
      final response = await http.put(
        fetchUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'equipmentIds': selectedEquipment.toList(),
        }),
      );

      if (response.statusCode == 200) {
        if (!isUpdateEquipment) {
          showSnackBarMessage('success'.tr, 'success_save_equipment'.tr,
              success: true);
          final userController = Get.find<UserController>();
          await userController.saveUserEquipment();
          final workoutResponse = await generateWorkoutPlan(userId: userId);

          if (workoutResponse.statusCode == 200) {
            showSnackBarMessage(
              'success'.tr,
              'success_generate_wo'.tr,
              success: true,
            );
            Get.off(() => MainPage());
          } else {
            showSnackBarMessage(
              'failed'.tr,
              'failed_generate_wo'.tr +
                  ' (Status: ${workoutResponse.statusCode})',
            );
          }
        } else {
          Get.back();
          showSnackBarMessage('success'.tr, 'success_update_equipment'.tr,
              success: true);
        }
      } else {
        showSnackBarMessage(
          'failed'.tr,
          'error_save_equipment' + ' (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      showSnackBarMessage('failed'.tr, 'server_connect_error'.tr + ' $e');
    }
    setLoading(false);
  }
}
