import 'package:flutter/material.dart';
import 'failures.dart';

class FailureHandler {
  static void handle(BuildContext context, Failure failure) {
    final message = failure.message;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
