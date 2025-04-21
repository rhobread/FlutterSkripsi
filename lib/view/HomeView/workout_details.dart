import 'package:flutter/material.dart';

class WorkoutDetailsPage extends StatelessWidget {
  final String day;
  final List<Map<String, dynamic>> exercises;

  const WorkoutDetailsPage({
    super.key,
    required this.day,
    required this.exercises,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "$day Details", // ✅ Now shows "{day} Details" instead of "Workout Details - {day}"
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: exercises.isEmpty
          ? const Center(
              child: Text(
                "No exercises available",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.fitness_center, color: Colors.blue, size: 24),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  exercise['name'] ?? "Unnamed Exercise",
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          _buildDetailRow("Sets", exercise['sets']),
                          _buildDetailRow("Reps", exercise['reps']),
                          _buildDetailRow("Weight", exercise['weight'] != null ? "${exercise['weight']} kg" : "Bodyweight"),
                          _buildDetailRow("Duration", "${exercise['totalDuration']} min"),
                          _buildDetailRow("Group", exercise['group']?['name'] ?? "N/A"),
                          _buildDetailRow("Difficulty", _difficultyLabel(exercise['group']?['difficulty'])),
                          _buildDetailRow("Muscles Hit", _formatMuscles(exercise['musclesHit'])),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  // Helper method to create a detail row
  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value?.toString() ?? "N/A", style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }

  // Formats the "Muscles Hit" list into a string
  String _formatMuscles(dynamic muscles) {
    if (muscles is List && muscles.isNotEmpty) {
      return muscles.join(", ");
    }
    return "N/A";
  }

  // Converts difficulty level to a readable format
  String _difficultyLabel(dynamic difficulty) {
    if (difficulty == null) return "N/A";
    switch (difficulty) {
      case 1:
        return "Beginner";
      case 2:
        return "Intermediate";
      case 3:
        return "Advanced";
      default:
        return "Unknown";
    }
  }
}
