import 'package:flutter/material.dart';

class WorkoutDetailsPage extends StatelessWidget {
  final String day;
  final int workoutId;
  final bool isWorkoutDay;
  final bool isToday;

  const WorkoutDetailsPage({
    super.key,
    required this.day,
    required this.workoutId,
    required this.isWorkoutDay,
    required this.isToday

  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "$day Workout Details", // ✅ Now shows "{day} Details" instead of "Workout Details - {day}"
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      )
    );
      
  }

}