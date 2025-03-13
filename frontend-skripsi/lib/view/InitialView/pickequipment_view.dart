import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:flutter_application_1/service/InitialService/pickequipment_service.dart';

class PickEquipmentPage extends StatefulWidget {
  final bool isGymSelected;

  const PickEquipmentPage({super.key, required this.isGymSelected});

  @override
  _PickEquipmentPageState createState() => _PickEquipmentPageState();
}

class _PickEquipmentPageState extends State<PickEquipmentPage> {
  List<Map<String, dynamic>> _equipmentList = [];
  List<Map<String, dynamic>> _filteredEquipmentList = [];
  Set<int> _selectedEquipment = {};
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  final PickEquipmentService _pickEquipmentService = PickEquipmentService();
  final userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    _initializeEquipment();
    _searchController.addListener(_filterEquipment);
  }

  void _initializeEquipment() async {
    List<Map<String, dynamic>> equipments =
        await _pickEquipmentService.fetchEquipments(
      context: context,
      isGymSelected: widget.isGymSelected,
    );
    setState(() {
      _equipmentList = equipments;
      _filteredEquipmentList = equipments;
      if (widget.isGymSelected) {
        _selectedEquipment =
            _equipmentList.map<int>((e) => e['id'] as int).toSet();
      }
    });
  }

  void _filterEquipment() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEquipmentList = _equipmentList
          .where((item) => item['name'].toLowerCase().contains(query))
          .toList();
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

  void _submitSelection() {
    _pickEquipmentService.submitEquipmentSelection(
      context: context,
      userId: userController.userId.value,
      selectedEquipment: _selectedEquipment,
      setLoading: (value) => setState(() => _isLoading = value),
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
                    color: Colors.white),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Equipment...',
                prefixIcon: Icon(Icons.search, color: Colors.black),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: _filteredEquipmentList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView.builder(
                      itemCount: _filteredEquipmentList.length,
                      itemBuilder: (context, index) {
                        final item = _filteredEquipmentList[index];
                        final isSelected =
                            _selectedEquipment.contains(item['id']);

                        return GestureDetector(
                          onTap: () => _toggleSelection(item['id']),
                          child: Card(
                            elevation: 2,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.black.withOpacity(0.1),
                                radius: 25,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: Image.asset(
                                    item['image'],
                                    fit: BoxFit.cover,
                                    width: 50,
                                    height: 50,
                                    errorBuilder: (context, error,
                                            stackTrace) =>
                                        const Icon(Icons.image_not_supported,
                                            color: Colors.grey),
                                  ),
                                ),
                              ),
                              title: Text(
                                item['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              trailing: Checkbox(
                                value: isSelected,
                                onChanged: (bool? newValue) =>
                                    _toggleSelection(item['id']),
                                activeColor: Colors.black,
                                checkColor: Colors.white,
                              ),
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
