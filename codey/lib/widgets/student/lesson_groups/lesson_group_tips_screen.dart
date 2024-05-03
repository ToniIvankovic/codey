import 'package:codey/models/entities/lesson_group.dart';
import 'package:codey/widgets/student/lessons/lessons_screen.dart';
import 'package:flutter/material.dart';

class LessonGroupTipsScreen extends StatelessWidget {
  final LessonGroup lessonGroup;
  final bool lessonGroupFinished;
  final bool? backDisabled;

  const LessonGroupTipsScreen({
    Key? key,
    required this.lessonGroup,
    required this.lessonGroupFinished,
    this.backDisabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lessonGroup.name),
        //disable back button
        automaticallyImplyLeading: !(backDisabled ?? false),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(lessonGroup.tips!),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50.0),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LessonsScreen(
                            lessonGroup: lessonGroup,
                            lessonGroupFinished: lessonGroupFinished),
                      ),
                    ),
                    child: const Text('Idi na lekcije'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
