import 'package:flutter/material.dart';

class HistoryDetailsPage extends StatelessWidget {
  final String day;
  final List<Map<String, dynamic>> exercises;

  const HistoryDetailsPage({
    Key? key,
    required this.day,
    required this.exercises,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "$day Details",
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
                  final details = exercise['details'] ?? {};
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
                          // Exercise title row
                          Row(
                            children: [
                              const Icon(Icons.fitness_center, color: Colors.blue, size: 24),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  exercise['exercise_name'] ?? "Unnamed Exercise",
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Exercise detail rows
                          _buildDetailRow("Sets", details['sets_done']),
                          _buildDetailRow("Reps", _formatList(details['reps'])),
                          _buildDetailRow("Weight", details['weight_used'] != null ? "${_formatList(details['weight_used'])} kg" : "Bodyweight"),
                          _buildDetailRow("Duration", "${details['totalDuration']} min"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  // Helper method for building a detail row.
  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
              child: Text(
            value?.toString() ?? "N/A",
            style: const TextStyle(color: Colors.black87),
          )),
        ],
      ),
    );
  }

  // Helper method to format list values (e.g., reps or weight_used).
  String _formatList(dynamic list) {
    if (list is List && list.isNotEmpty) {
      return list.join(", ");
    }
    return "N/A";
  }
}
