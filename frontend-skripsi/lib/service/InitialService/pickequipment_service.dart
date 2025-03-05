import 'dart:convert';
import 'package:http/http.dart' as http;

class PickEquipmentService {
  static const String _baseUrl = 'http://10.0.2.2:3005';

  Future<List<Map<String, dynamic>>> fetchEquipments() async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/workout/equipments'));
      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = jsonBody['data'];
        return data
            .map((item) => {
                  'id': item['id'],
                  'name': item['name'],
                  'image': 'lib/assets/${item['image']}'
                })
            .toList();
      } else {
        throw Exception('Error fetching equipment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<bool> submitEquipmentSelection(
      String userId, List<int> selectedEquipment) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/user/equipments/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'equipmentIds': selectedEquipment}),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error saving selection: $e');
    }
  }
}
