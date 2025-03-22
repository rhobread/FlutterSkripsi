import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  List<Map<String, dynamic>> _orderedWeek = [];
  bool _isLoading = true;
  String _today = DateFormat('EEEE').format(DateTime.now()); // ✅ Get today’s day

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {

      final workouts = await homeService.fetchWorkouts(
        context: context,
        userId: userController.userId.value,
      );


      setState(() {
        _orderedWeek = _generateOrderedWeek(workouts);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showSnackBarMessage(context, e.toString());
    }
  }

  /// ✅ Generate ordered week with correct day sequence & rest days in between
  List<Map<String, dynamic>> _generateOrderedWeek(List<Map<String, dynamic>> workouts) {
    List<String> allDays = [
      "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
    ];
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

    // ✅ Create an ordered list with rest days between workouts
    List<Map<String, dynamic>> orderedWeek = [];
    for (var day in allDays) {
      if (week.containsKey(day)) {
        orderedWeek.add({"day": day, ...week[day]!});
      } else {
        orderedWeek.add({"day": day, "type": "rest"}); // ✅ Insert rest day
      }
    }

    return orderedWeek;
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
          : _orderedWeek.isEmpty
              ? const Center(
                  child: Text(
                    "No workouts available",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : SingleChildScrollView( // ✅ Enables scrolling
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true, // ✅ Ensures it doesn't take full height
                        physics: const NeverScrollableScrollPhysics(), // ✅ Prevents conflicts
                        itemCount: _orderedWeek.length,
                        itemBuilder: (context, index) {
                          String day = _orderedWeek[index]["day"];
                          Map<String, dynamic> details = _orderedWeek[index];
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
                                        isWorkoutDay ? day : "Rest Day", // ✅ Show actual day name
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
}
