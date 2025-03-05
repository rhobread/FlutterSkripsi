import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PickEquipmentPage extends StatefulWidget {
  final String userId;
  final bool isGymSelected;

  const PickEquipmentPage({
    super.key,
    required this.userId,
    required this.isGymSelected,
  });

  @override
  _PickEquipmentPageState createState() => _PickEquipmentPageState();
}

class _PickEquipmentPageState extends State<PickEquipmentPage> {
  List<Map<String, dynamic>> _equipmentList = [];
  Set<int> _selectedEquipment = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchEquipments();
  }

  Future<void> _fetchEquipments() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3005/workout/equipments'),
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = jsonBody['data'];

        setState(() {
          _equipmentList = data.map((item) {
            return {
              'id': item['id'],
              'name': item['name'],
              'image': 'lib/assets/${item['image']}',
            };
          }).toList();

          if (widget.isGymSelected) {
            _selectedEquipment =
                _equipmentList.map<int>((e) => e['id']).toSet();
          }
        });
      } else {
        _showMessage(
            'Error fetching equipment. (Status: ${response.statusCode})');
      }
    } catch (e) {
      _showMessage('Error fetching equipment: $e');
    }
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedEquipment.contains(id)) {
        _selectedEquipment.remove(id);
      } else {
        _selectedEquipment.add(id);
      }
    });
  }

  Future<void> _submitSelection() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3005/user/equipments/${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'equipmentIds': _selectedEquipment.toList(),
        }),
      );

      if (response.statusCode == 200) {
        _showMessage('Equipment saved successfully!', success: true);
      } else {
        _showMessage(
            'Error saving selection. (Status: ${response.statusCode})');
      }
    } catch (e) {
      _showMessage('Network error: $e');
    }

    setState(() => _isLoading = false);
  }

  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            color: Colors.black,
            height: 100,
            width: double.infinity,
            alignment: Alignment.center,
            child: const SafeArea(
              child: Text(
                'JymMat',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Select Your Equipment',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Tap to select/unselect equipment',
            style: TextStyle(fontSize: 14, color: Colors.black),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _equipmentList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      itemCount: _equipmentList.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.9,
                      ),
                      itemBuilder: (context, index) {
                        final item = _equipmentList[index];
                        final isSelected =
                            _selectedEquipment.contains(item['id']);

                        return GestureDetector(
                          onTap: () => _toggleSelection(item['id']),
                          child: Card(
                            color: isSelected ? Colors.black : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected ? Colors.white : Colors.black,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: isSelected,
                                      onChanged: (bool? newValue) {
                                        _toggleSelection(item['id']);
                                      },
                                      activeColor: Colors.white,
                                      checkColor: Colors.black,
                                    ),
                                    Expanded(
                                      child: Text(
                                        item['name'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                      bottom: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        item['image'],
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Center(
                                            child: Text(
                                              'No image',
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Continue'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
