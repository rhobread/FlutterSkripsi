import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:workout_skripsi_app/service/CommonService/export_service.dart';
import 'package:workout_skripsi_app/service/HomeService/history_service.dart';
import 'package:workout_skripsi_app/view/HomeView/workoutDetails_view.dart';
import 'package:workout_skripsi_app/controller/user_controller.dart';

class HistoryWorkoutPage extends StatefulWidget {
  const HistoryWorkoutPage({super.key});

  @override
  State<HistoryWorkoutPage> createState() => _HistoryWorkoutPageState();
}

class _HistoryWorkoutPageState extends State<HistoryWorkoutPage> {
  final historyService = HistoryService();
  final userController = Get.find<UserController>();

  List<Map<String, dynamic>> _exercises = [];
  bool _isLoading = true;
  bool _isAscending = false;

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
      final data = await historyService.getCompletedWorkouts(
        userId: userController.userId.value,
      );

      // Parse "Friday, 25th April 2025" to DateTime
      for (var ex in data) {
        ex['date_raw'] = _parseCustomDate(ex['date']);
      }

      setState(() {
        _exercises = data;
        _sortExercises();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showSnackBarMessage('Failed to load exercises', e.toString());
    }
  }

  DateTime _parseCustomDate(String dateStr) {
    // Remove ordinal suffixes from day numbers
    final cleaned = dateStr.replaceAllMapped(
      RegExp(r'(\d+)(st|nd|rd|th)'),
      (match) => match.group(1)!,
    );
    try {
      return DateFormat('EEEE, d MMMM yyyy').parse(cleaned);
    } catch (_) {
      return DateTime.now();
    }
  }

  void _sortExercises() {
    _exercises.sort((a, b) {
      final dateA = a['date_raw'] as DateTime;
      final dateB = b['date_raw'] as DateTime;
      return _isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });
  }

  void _toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending;
      _sortExercises();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: buildCustomAppBar(
          title: 'workout_history'.tr,
          elevation: 1,
          extraActions: [
            IconButton(
              onPressed: _toggleSortOrder,
              icon: Icon(
                _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                color: Colors.black,
              ),
              tooltip: 'sort_by_date'.tr,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _exercises.isEmpty
                    ? Center(
                        child: Text(
                          'no_workouts_yet'.tr,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _exercises.length,
                        itemBuilder: (context, index) {
                          final ex = _exercises[index];
                          final String date = ex['date'];
                          final int workoutId = ex['workout_id'] is int
                              ? ex['workout_id'] as int
                              : int.tryParse(
                                      ex['workout_id']?.toString() ?? '') ??
                                  0;

                          return GestureDetector(
                            onTap: () => Get.to(() => WorkoutDetailsPage(
                                  day: date,
                                  workoutId: workoutId,
                                  isToday: false,
                                  isDone: true,
                                )),
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
                                  const Icon(Icons.check_circle,
                                      color: Colors.green),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      date,
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
