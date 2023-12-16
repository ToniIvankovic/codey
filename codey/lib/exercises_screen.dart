import 'package:codey/models/lesson.dart';
import 'package:flutter/material.dart';

class ExercisesScreen extends StatelessWidget {
  final Lesson lesson;

  ExercisesScreen({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercises'),
      ),
      body: Center(
        child: Text('Exercises Screen for Lesson: ${lesson.name}'),
      ),
    );
  }
}