import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/view/HomeView/home_view.dart';

class PickEquipmentService {
  Future<List<Map<String, dynamic>>> fetchEquipments({
    required BuildContext context,
    required bool isGymSelected,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3005/workout/equipments'),
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = jsonBody['data'];

        List<Map<String, dynamic>> equipmentList = data.map((item) {
          return {
            'id': item['id'],
            'name': item['name'],
            'image': 'lib/assets/${item['image']}',
          };
        }).toList();

        return equipmentList;
      } else {
        _showMessage(context, 'Error fetching equipment. (Status: ${response.statusCode})');
        return [];
      }
    } catch (e) {
      _showMessage(context, 'Error fetching equipment: $e');
      return [];
    }
  }

  Future<void> submitEquipmentSelection({
    required BuildContext context,
    required String userId,
    required Set<int> selectedEquipment,
    required Function(bool) setLoading,
  }) async {
    setLoading(true);
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3005/user/equipments/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'equipmentIds': selectedEquipment.toList(),
        }),
      );

      if (response.statusCode == 200) {
        _showMessage(context, 'Equipment saved successfully!', success: true);
        // Navigate to HomePage on success
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        _showMessage(context, 'Error saving selection. (Status: ${response.statusCode})');
      }
    } catch (e) {
      _showMessage(context, 'Network error: $e');
    }
    setLoading(false);
  }

  void _showMessage(BuildContext context, String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}
