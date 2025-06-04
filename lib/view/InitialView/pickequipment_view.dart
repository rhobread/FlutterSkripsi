import 'package:workout_skripsi_app/service/CommonService/export_service.dart';
import 'package:workout_skripsi_app/service/InitialService/pickEquipment_service.dart';

class PickEquipmentPage extends StatefulWidget {
  final bool isGymSelected;
  final bool isUpdateEquipment;

  const PickEquipmentPage(
      {super.key,
      required this.isGymSelected,
      required this.isUpdateEquipment});

  @override
  _PickEquipmentPageState createState() => _PickEquipmentPageState();
}

class _PickEquipmentPageState extends State<PickEquipmentPage> {
  List<Map<String, dynamic>> _equipmentList = [];
  List<Map<String, dynamic>> _userequipments = [];
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
    if (widget.isUpdateEquipment) {
      _userequipments = await _pickEquipmentService.getUserEquipments(
          userId: userController.userId.value);
    }

    List<Map<String, dynamic>> equipments =
        await _pickEquipmentService.fetchEquipments(
      isGymSelected: widget.isGymSelected,
    );

    setState(() {
      _equipmentList = equipments;
      _filteredEquipmentList = equipments;

      if (widget.isGymSelected) {
        _selectedEquipment =
            _equipmentList.map<int>((e) => e['id'] as int).toSet();
      }

      if (widget.isUpdateEquipment) {
        _selectedEquipment
            .addAll(_userequipments.map<int>((e) => e['id'] as int));
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

  void _submitSelection() async {
    await _pickEquipmentService.submitEquipmentSelection(
      userId: userController.userId.value,
      selectedEquipment: _selectedEquipment,
      isUpdateEquipment: widget.isUpdateEquipment,
      setLoading: (value) => setState(() => _isLoading = value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildMainHeader(
          showBackButton: widget.isUpdateEquipment, context: context),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 30),
          Text(
            'select_equipment'.tr,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'tap_select_equipment'.tr,
            style: TextStyle(fontSize: 14, color: Colors.black),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'search_equipment'.tr + '...',
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
            child: buildCustomButton(
              label: widget.isUpdateEquipment ? 'update'.tr : 'continue'.tr,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _submitSelection,
            ),
          ),
        ],
      ),
    );
  }
}
