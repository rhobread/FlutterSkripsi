import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:flutter_application_1/service/HomeService/history_service.dart';
import 'package:flutter_application_1/view/HomeView/workout_details.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final historyService = HistoryService();
  final userController = Get.find<UserController>();

  // Grouped history by date (key: date string, value: list of exercise history items)
  Map<String, List<Map<String, dynamic>>> _historyByDate = {};
  bool _isLoading = true;

  // Default to the current month (set to the 1st day) for both start and end.
  DateTime _selectedStartMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _selectedEndMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  Future<void> _loadHistoryData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Format the selected months as yyyyMM (e.g., "202502") for API usage.
      final String start = DateFormat('yyyyMM').format(_selectedStartMonth);
      final String end = DateFormat('yyyyMM').format(_selectedEndMonth);

      final data = await historyService.getHistory(
        userId: userController.userId.value,
        startMonth: start,
        endMonth: end,
      );

      // Flatten the list of exercises (each with its history array) into a map grouped by date.
      final historyMap = _generateHistoryByDate(data);
      setState(() {
        _historyByDate = historyMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showSnackBarMessage('Failed!', e.toString());
    }
  }
  /// Flattens the exercise history by grouping each history record by its date.
  Map<String, List<Map<String, dynamic>>> _generateHistoryByDate(
      List<Map<String, dynamic>> exercisesHistory) {
    final Map<String, List<Map<String, dynamic>>> map = {};
    for (var exercise in exercisesHistory) {
      final String exerciseCd = exercise['exercise_cd'];
      final String exerciseName = exercise['exercise_name'];
      final exerciseImage = exercise['exercise_image'];
      final List<dynamic> histories = exercise['history'];
      for (var record in histories) {
        final String dateStr = record['date'];
        final historyItem = {
          'exercise_cd': exerciseCd,
          'exercise_name': exerciseName,
          'exercise_image': exerciseImage,
          'details': record,
        };
        if (map.containsKey(dateStr)) {
          map[dateStr]!.add(historyItem);
        } else {
          map[dateStr] = [historyItem];
        }
      }
    }
    return map;
  }

  /// Shows a date picker that lets the user pick a month.
  /// It forces the selection to the first day of the month.
  Future<DateTime?> _pickMonth(DateTime initialDate, String helpText) async {
    // Ensure the initial date is set to the first day of its month.
    final DateTime initial = DateTime(initialDate.year, initialDate.month, 1);
    return await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2100, 12, 31),
      helpText: helpText,
      selectableDayPredicate: (date) {
        // Only allow selection of the first day to simulate a month picker.
        return date.day == 1;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build a sorted list of date keys.
    final List<String> sortedDates = _historyByDate.keys.toList()
      ..sort((a, b) {
        try {
          final dateA = DateFormat('EEEE, d MMMM yyyy').parse(a);
          final dateB = DateFormat('EEEE, d MMMM yyyy').parse(b);
          return dateA.compareTo(dateB);
        } catch (_) {
          return a.compareTo(b);
        }
      });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: buildCustomAppBar(title: "History"),
      ),
      body: Column(
        children: [
          // Date Range Picker Row
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
                      setState(() {
                        _selectedStartMonth = newDate;
                      });
                      _loadHistoryData();
                    },
                  ),
                ),
                const SizedBox(width: 8),  // <-- Add a space of 8 pixels
                Expanded(
                  child: buildMonthPickerTile(
                    context: context,
                    selectedMonth: _selectedEndMonth,
                    label: 'End',
                    pickMonth: _pickMonth,
                    onMonthChanged: (newDate) {
                      setState(() {
                        _selectedEndMonth = newDate;
                      });
                      _loadHistoryData();
                    },
                  ),
                ),
              ],
            ),
          ),
          // History List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _historyByDate.isEmpty
                    ? const Center(
                        child: Text(
                          "No history available",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: sortedDates.length,
                        itemBuilder: (context, index) {
                          final dateKey = sortedDates[index];
                          final exercises = _historyByDate[dateKey]!;
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WorkoutDetailsPage(
                                    day: dateKey,
                                    exercises: exercises,
                                  ),
                                ),
                              );
                            },
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dateKey,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        exercises.isNotEmpty
                                            ? exercises[0]['exercise_name'] ??
                                                "Workout"
                                            : "",
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                  const Icon(Icons.arrow_forward_ios,
                                      color: Colors.black54),
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
