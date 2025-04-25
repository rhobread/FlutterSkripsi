import 'package:flutter_application_1/view/HomeView/historyExercise_view.dart';
import 'package:flutter_application_1/view/HomeView/historyWorkout_view.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/service/HomeService/history_service.dart';
import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:flutter_application_1/view/HomeView/workoutDetails_view.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryService historyService = HistoryService();
  final userController = Get.find<UserController>();

  List<Map<String, dynamic>> _exercises = [];
  List<Map<String, dynamic>> _workouts = [];

  bool _loadingExercises = true;
  bool _loadingWorkouts = true;

  @override
  void initState() {
    super.initState();
    _loadExerciseHistory();
    _loadWorkoutHistory();
  }

  Future<void> _loadExerciseHistory() async {
    setState(() => _loadingExercises = true);
    final now = DateTime.now();
    final start = DateFormat('yyyyMM').format(DateTime(now.year, now.month, 1));
    final end = start;
    final all = await historyService.getExerciseHistory(
      userId: userController.userId.value,
      startMonth: start,
      endMonth: end,
    );
    setState(() {
      _exercises = all.take(3).toList();
      _loadingExercises = false;
    });
  }

  Future<void> _loadWorkoutHistory() async {
    setState(() => _loadingWorkouts = true);
    final all = await historyService.getCompletedWorkouts(
      userId: userController.userId.value,
    );
    setState(() {
      _workouts = all.take(3).toList(); // only top-3
      _loadingWorkouts = false;
    });
  }

  void _showDetailSheet(int exerciseId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          DetailSheetContent(exerciseId: exerciseId, isHistory: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final divider = Divider(height: 1, thickness: 1, color: Colors.grey[300]);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: buildCustomAppBar(title: "History"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise History Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Exercise History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HistoryExercisePage()),
                    ),
                    child: const Text('View all',
                        style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            ),

            // Exercise History List
            if (_loadingExercises)
              const Center(child: CircularProgressIndicator())
            else if (_exercises.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No exercises found',
                    style: TextStyle(color: Colors.grey)),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _exercises.length,
                separatorBuilder: (_, __) => divider,
                itemBuilder: (context, i) {
                  final ex = _exercises[i];
                  final String rawName = ex['exercise_name'] ?? 'Unnamed';
                  final String name = rawName.split('(').first.trim();
                  final img = ex['exercise_image'] as String? ?? '';
                  final id = ex['exercise_id']?.hashCode ?? i;

                  return GestureDetector(
                    onTap: () => _showDetailSheet(id),
                    child: Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: img.isNotEmpty
                                ? Image.asset(img,
                                    width: 50, height: 50, fit: BoxFit.cover)
                                : Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.fitness_center,
                                        color: Colors.grey),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              size: 16, color: Colors.black54),
                        ],
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 24),

            // Workout History Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Workout History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HistoryWorkoutPage()),
                    ),
                    child: const Text('View all',
                        style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            ),

            // Workout History List (top 3, with green checkbox)
            if (_loadingWorkouts)
              const Center(child: CircularProgressIndicator())
            else if (_workouts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No workouts yet',
                    style: TextStyle(color: Colors.grey)),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _workouts.length,
                separatorBuilder: (_, __) => divider,
                itemBuilder: (context, i) {
                  final w = _workouts[i];
                  final date = w['date'] as String;
                  final id = w['workout_id'] as int;

                  return GestureDetector(
                    onTap: () {
                      Get.to(() => WorkoutDetailsPage(
                            day: date,
                            workoutId: id,
                            isToday: false,
                            isDone: true,
                          ));
                    },
                    child: Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              date,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              size: 16, color: Colors.black54),
                        ],
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
