import 'package:flutter/material.dart';

void showSnackBarMessage(BuildContext context, String message, {bool success = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: success ? Colors.green : Colors.red,
    ),
  );
}
