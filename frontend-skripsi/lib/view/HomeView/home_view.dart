import 'package:intl/intl.dart';
import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:flutter_application_1/service/HomeService/home_service.dart';
import 'package:flutter_application_1/view/HomeView/workout_details.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final homeService = HomeService();
  final userController = Get.find<UserController>();
  Map<String, Map<String, dynamic>> _weekSchedule = {};
  bool _isLoading = true;
  String _today = DateFormat('EEEE').format(DateTime.now()); 

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

  /// ✅ Generate a full week with workouts & rest days
  Map<String, Map<String, dynamic>> _generateFullWeek(List<Map<String, dynamic>> workouts) {
    Map<String, Map<String, dynamic>> week = {};

    // ✅ Add workouts to their respective days
    for (var workout in workouts) {
      final dayOnly = workout['date'].split(",")[0]; // Extract day name
      week[dayOnly] = {
        "type": "workout",
        "exercises": (workout['exercises'] as List<dynamic>)
            .map((e) => Map<String, dynamic>.from(e))
            .toList(),
      };
    }

    // ✅ Add rest days for any missing days
    List<String> allDays = [
      "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
    ];
    for (var day in allDays) {
      if (!week.containsKey(day)) {
        week[day] = {"type": "rest"};
      }
    }

    return week;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // ✅ Light background
      appBar: AppBar(
        title: Obx(() => Text(
              "Welcome, ${userController.userName.value}",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            )),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
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
              : SingleChildScrollView( // ✅ Wrap with scrollable container
                  child: Column(
                    children: [
                      const SizedBox(height: 10), // ✅ Adds spacing at the top
                      ListView.builder(
                        shrinkWrap: true, // ✅ Ensures it doesn't take full height
                        physics: const NeverScrollableScrollPhysics(), // ✅ Prevents conflicts
                        itemCount: _weekSchedule.length,
                        itemBuilder: (context, index) {
                          String day = _weekSchedule.keys.elementAt(index);
                          Map<String, dynamic> details = _weekSchedule[day]!;
                          bool isWorkoutDay = details["type"] == "workout";
                          bool isToday = day == _today; // ✅ Highlight today

                          // ✅ Styling
                          final Color bgColor = isToday ? const Color(0xFF3757F7) : Colors.white;
                          final Color textColor = isToday ? Colors.white : Colors.black;
                          final FontWeight titleWeight = FontWeight.bold;

                          return GestureDetector(
                            onTap: () {
                              if (!isWorkoutDay) return; // 🔒 Prevent tapping rest days
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WorkoutDetailsPage(
                                    day: day,
                                    exercises: details["exercises"],
                                  ),
                                ),
                              );
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
                                        isWorkoutDay ? "Day ${_getDayIndex(day)}" : "Rest Day",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: titleWeight,
                                          color: textColor,
                                        ),
                                      ),
                                      if (isWorkoutDay)
                                        Text(
                                          details["exercises"].isNotEmpty
                                              ? details["exercises"][0]['group']['name'] ?? "Workout"
                                              : "",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isToday ? Colors.white70 : Colors.black54,
                                          ),
                                        ),
                                    ],
                                  ),
                                  isWorkoutDay
                                      ? (isToday
                                          ? ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => WorkoutDetailsPage(
                                                      day: day,
                                                      exercises: details["exercises"],
                                                    ),
                                                  ),
                                                );
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
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                          : const Icon(Icons.lock, color: Colors.black54))
                                      : const SizedBox(), // No lock icon for rest days
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20), // ✅ Adds bottom padding
                    ],
                  ),
                ),
    );
  }

  /// ✅ Get numeric order of the day in the week
  int _getDayIndex(String day) {
    List<String> allDays = [
      "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
    ];
    return allDays.indexOf(day) + 1;
  }
}
