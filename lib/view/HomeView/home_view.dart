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

  Map<String, Map<String, dynamic>> _generateFullWeek(List<Map<String, dynamic>> workouts) {
  // 1) Build a lookup of workout-data by weekday name:
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

  // 2) Define the canonical order:
  const List<String> allDays = [
    "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
  ];

  // 3) Build the week map *in* that exact order:
  final Map<String, Map<String, dynamic>> week = {};
  for (var day in allDays) {
    if (workoutsByDay.containsKey(day)) {
      week[day] = workoutsByDay[day]!;
    } else {
      week[day] = {"type": "rest"};
    }
  }

  return week;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light background
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
              : SingleChildScrollView( // Wrap with scrollable container
                  child: Column(
                    children: [
                      const SizedBox(height: 10), //  Adds spacing at the top
                      ListView.builder(
                        shrinkWrap: true, // Ensures it doesn't take full height
                        physics: const NeverScrollableScrollPhysics(), //  Prevents conflicts
                        itemCount: _weekSchedule.length,
                        itemBuilder: (context, index) {
                          String day = _weekSchedule.keys.elementAt(index);
                          Map<String, dynamic> details = _weekSchedule[day]!;
                          bool isWorkoutDay = details["type"] == "workout";
                          bool isToday = day == _today; 
                          // Styling
                          final Color bgColor = isToday ? const Color(0xFF3757F7) : Colors.white;
                          final Color textColor = isToday ? Colors.white : Colors.black;
                          final FontWeight titleWeight = FontWeight.bold;

                          return GestureDetector(
                            onTap: () {
                              if (!isWorkoutDay) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WorkoutDetailsPage(
                                    day: day,
                                    workoutId: details['workout_id'],
                                    isWorkoutDay: isWorkoutDay,
                                    isToday: isToday,
                                    
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
                                        isWorkoutDay ? day : "Rest Day",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: titleWeight,
                                          color: textColor,
                                        ),
                                      ),
                                      if (isWorkoutDay)
                                        Text.rich(
                                          TextSpan(
                                            style: TextStyle(
                                              fontSize: 14,                            // default for status text
                                              color: isToday ? Colors.white70 : Colors.black54,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: details["status"].isNotEmpty 
                                                    ? details["status"] 
                                                    : "",
                                              ),
                                              if (details["status"].isNotEmpty)
                                                TextSpan(
                                                  text: ', (${details['totalWorkoutDuration']} Minutes)',
                                                  style: TextStyle(
                                                    fontSize: 12,                       // smaller size for duration
                                                    fontWeight: FontWeight.normal,
                                                  ),
                                                ),
                                            ],
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
                                                      workoutId: details['workout_id'],
                                                      isWorkoutDay: isWorkoutDay,
                                                      isToday: isToday,
                                                      
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
                      const SizedBox(height: 20), //  Adds bottom padding
                    ],
                  ),
                ),
    );
  }

  /// ✅ Get numeric order of the day in the week

}
