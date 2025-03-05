import 'package:flutter/material.dart';
import 'package:flutter_application_1/service/InitialService/pickequipment_service.dart';

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

  final PickEquipmentService _pickEquipmentService = PickEquipmentService();

  @override
  void initState() {
    super.initState();
    _initializeEquipment();
  }

  void _initializeEquipment() async {
    List<Map<String, dynamic>> equipments = await _pickEquipmentService.fetchEquipments(
      context: context,
      isGymSelected: widget.isGymSelected,
    );
    setState(() {
      _equipmentList = equipments;
      if (widget.isGymSelected) {
        _selectedEquipment = _equipmentList.map<int>((e) => e['id'] as int).toSet();
      }
    });
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

  void _setLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  void _submitSelection() {
    _pickEquipmentService.submitEquipmentSelection(
      context: context,
      userId: widget.userId,
      selectedEquipment: _selectedEquipment,
      setLoading: _setLoading,
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
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.9,
                      ),
                      itemBuilder: (context, index) {
                        final item = _equipmentList[index];
                        final isSelected = _selectedEquipment.contains(item['id']);
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
                                          color: isSelected ? Colors.white : Colors.black,
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
                                        errorBuilder: (context, error, stackTrace) {
                                          return Center(
                                            child: Text(
                                              'No image',
                                              style: TextStyle(
                                                color: isSelected ? Colors.white : Colors.black,
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
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
