import 'package:intl/intl.dart';
import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:flutter_application_1/service/HomeService/home_service.dart';
import 'package:flutter_application_1/view/HomeView/workoutDetails_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final homeService = HomeService();
  final userController = Get.find<UserController>();
  final String _today = DateFormat('EEEE').format(DateTime.now()); 
  Map<String, Map<String, dynamic>> _weekSchedule = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final workouts = await homeService.fetchWorkouts(
        userId: userController.userId.value,
      );
      setState(() {
        _weekSchedule = _generateFullWeek(workouts);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showSnackBarMessage('Failed!', e.toString());
    }
  }

  Map<String, Map<String, dynamic>> _generateFullWeek(List<Map<String, dynamic>> workouts) {
    final Map<String, Map<String, dynamic>> workoutsByDay = {};
    for (var workout in workouts) {
      final dayOnly = workout['date'].split(',')[0];
      workoutsByDay[dayOnly] = {
        "workout_id": workout['workout_id'],
        "type": "workout",
        "status": workout['status'],
        "totalWorkoutDuration": workout['totalWorkoutDuration'],
      };
    }

    const List<String> allDays = [
      "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
    ];

    final Map<String, Map<String, dynamic>> week = {};
    for (var day in allDays) {
      week[day] = workoutsByDay[day] ?? {"type": "rest"};
    }

    return week;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: buildCustomAppBar(dynamicTitle: userController.userName),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _weekSchedule.isEmpty
              ? const Center(
                  child: Text(
                    "No workouts available",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _weekSchedule.length,
                        itemBuilder: (context, index) {
                          final day = _weekSchedule.keys.elementAt(index);
                          final details = _weekSchedule[day]!;
                          final status = (details["status"] as String?)?.toLowerCase() ?? '';
                          final isWorkoutDay = details["type"] == "workout";
                          final isToday = day == _today;
                          final isDone = status == 'done';

                          // 1) Determine background
                          Color bgColor;
                          if (status == 'done') {
                            bgColor = Colors.green;
                          } else if (status == 'skipped') {
                            bgColor = Colors.yellow;
                          } else if (isToday) {
                            bgColor = const Color(0xFF3757F7);
                          } else {
                            bgColor = Colors.white;
                          }

                          // 2) Determine text color
                          Color textColor;
                          if (status == 'done') {
                            textColor = Colors.white;
                          } else if (status == 'skipped') {
                            textColor = Colors.black;
                          } else if (isToday) {
                            textColor = Colors.white;
                          } else {
                            textColor = Colors.black;
                          }

                          // 3) Right-side widget (icon/button)
                          Widget trailing;
                          if (!isWorkoutDay) {
                            trailing = const SizedBox();
                          } else if (status == 'done') {
                            trailing = const Icon(Icons.check, color: Colors.white);
                          } else if (status == 'skipped') {
                            trailing = const Icon(Icons.block, color: Colors.black54);
                          } else if (isToday) {
                            trailing = ElevatedButton(
                              onPressed: () {
                                Get.to(() => WorkoutDetailsPage(
                                  day: day,
                                  workoutId: details['workout_id'],
                                  isToday: isToday,
                                  isDone: false,
                                ));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF3757F7),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Start",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            );
                          } else {
                            trailing = const Icon(Icons.lock, color: Colors.black54);
                          }

                          return GestureDetector(
                            onTap: () {
                              // Only navigate if it's a workout and NOT already done
                              if (!isWorkoutDay) return;
                              Get.to(() => WorkoutDetailsPage(
                                day: day,
                                workoutId: details['workout_id'],
                                isToday: isToday,
                                isDone: isDone,
                              ));
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha((0.1 * 255).toInt()),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isWorkoutDay ? day : "Rest Day",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      if (isWorkoutDay)
                                        Text.rich(
                                          TextSpan(
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: (isToday || status == 'done')
                                                  ? Colors.white70
                                                  : Colors.black54,
                                            ),
                                            children: [
                                              TextSpan(text: details["status"] ?? ""),
                                              if ((details["status"] as String).isNotEmpty)
                                                TextSpan(
                                                  text: ', (${details['totalWorkoutDuration']} Minutes)',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.normal,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing,
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }
}
