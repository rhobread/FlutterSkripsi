import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//ShowSnakbarMessage
void showSnackBarMessage(BuildContext context, String message,
    {bool success = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: success ? Colors.green : Colors.red,
    ),
  );
}

//Generate Workout Plan
Future<http.Response> generateWorkoutPlan({required String userId}) async {
  try {
    return await http.post(
      Uri.parse('http://10.0.2.2:3005/workout/generate/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );
  } catch (e) {
    return http.Response('Network error: $e', 500);
  }
}
