import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:flutter_application_1/service/HomeService/history_service.dart';
import 'package:flutter_application_1/view/HomeView/workoutDetails_view.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:intl/intl.dart';

class HistoryExercisePage extends StatefulWidget {
  const HistoryExercisePage({super.key});

  @override
  State<HistoryExercisePage> createState() => _HistoryExercisePageState();
}

class _HistoryExercisePageState extends State<HistoryExercisePage> {
  final historyService = HistoryService();
  final userController = Get.find<UserController>();

  // Filter dates
  DateTime _selectedStartMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _selectedEndMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);

  // Loaded exercises
  List<Map<String, dynamic>> _exercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final start = DateFormat('yyyyMM').format(_selectedStartMonth);
      final end = DateFormat('yyyyMM').format(_selectedEndMonth);

      final data = await historyService.getExerciseHistory(
        userId: userController.userId.value,
        startMonth: start,
        endMonth: end,
      );

      setState(() {
        _exercises = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showSnackBarMessage('Failed to load exercises', e.toString());
    }
  }

  Future<DateTime?> _pickMonth(DateTime initialDate, String helpText) async {
    return showMonthPicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale("en"),
    );
  }

  void _showDetailSheet(int exerciseId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DetailSheetContent(exerciseId: exerciseId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: buildCustomAppBar(title: "Workout History"),
      ),
      body: Column(
        children: [
          // Month pickers row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: buildMonthPickerTile(
                    context: context,
                    selectedMonth: _selectedStartMonth,
                    label: 'Start',
                    pickMonth: _pickMonth,
                    onMonthChanged: (newDate) {
                      setState(() => _selectedStartMonth = newDate);
                      _loadExercises();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: buildMonthPickerTile(
                    context: context,
                    selectedMonth: _selectedEndMonth,
                    label: 'End',
                    pickMonth: _pickMonth,
                    onMonthChanged: (newDate) {
                      setState(() => _selectedEndMonth = newDate);
                      _loadExercises();
                    },
                  ),
                ),
              ],
            ),
          ),

          // Exercise list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _exercises.isEmpty
                    ? const Center(
                        child: Text(
                          "No exercises available",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _exercises.length,
                        itemBuilder: (context, index) {
                          final ex = _exercises[index];
                          final String name = ex['exercise_name'] ?? 'Unnamed';
                          final String? assetPath =
                              ex['exercise_image'] as String?;
                          final int exerciseId = ex['exercise_id'] is int
                              ? ex['exercise_id'] as int
                              : int.tryParse(
                                      ex['exercise_id']?.toString() ?? '') ??
                                  0;

                          return GestureDetector(
                            onTap: () => _showDetailSheet(exerciseId),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: assetPath != null &&
                                            assetPath.isNotEmpty
                                        ? Image.asset(
                                            assetPath,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            width: 50,
                                            height: 50,
                                            color: Colors.grey[200],
                                            child: const Icon(
                                              Icons.fitness_center,
                                              color: Colors.grey,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
