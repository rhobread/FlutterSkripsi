import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WorkoutPlanScreen(),
    );
  }
}

class WorkoutPlanScreen extends StatefulWidget {
  const WorkoutPlanScreen({super.key});

  @override
  _WorkoutPlanScreenState createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  Map<String, dynamic>? workoutPlan;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWorkoutPlan();
  }

  Future<void> fetchWorkoutPlan() async {
    const String url = 'http://localhost:3005/user/workout-plan/2';
    try {
      final response = await http.get(Uri.parse(url));
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        workoutPlan = {};
        for (var dayMap in data['data']) {
          workoutPlan!.addAll(dayMap);
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching workout plan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Plan')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : workoutPlan == null
              ? const Center(child: Text('Failed to load data'))
              : ListView.builder(
                  itemCount: workoutPlan!.keys.length,
                  itemBuilder: (context, index) {
                    String day = workoutPlan!.keys.elementAt(index);
                    List exercises = workoutPlan![day];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ExpansionTile(
                        title: Text(
                          day,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        children: exercises.map<Widget>((exercise) {
                          return ListTile(
                            title: Text(exercise['exercise']),
                            subtitle: Text(
                              'Time: ${exercise['total_time']} min\nMuscles: ${exercise['targetted_muscle'].join(', ')}',
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
    );
  }
}
