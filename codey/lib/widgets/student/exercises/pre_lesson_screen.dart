import 'package:codey/models/entities/app_user.dart';
import 'package:codey/models/entities/lesson.dart';
import 'package:codey/models/entities/lesson_group.dart';
import 'package:codey/widgets/student/exercises/exercises_screen.dart';
import 'package:flutter/material.dart';

class PreLessonScreen extends StatelessWidget {
  final Lesson lesson;
  final LessonGroup lessonGroup;
  final AppUser user;

  const PreLessonScreen({
    Key? key,
    required this.lesson,
    required this.lessonGroup,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var nextButton = TextButton.icon(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ExercisesScreen(
              lesson: lesson,
              lessonGroup: lessonGroup,
              user: user,
            ),
          ),
        );
      },
      icon: const Icon(Icons.play_arrow),
      label: const Text('Započni lekciju'),
    );
    if (lesson.specificTips == null || lesson.specificTips!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        nextButton.onPressed!();
      });
      return const Scaffold(body: Center(child: SizedBox.shrink()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        titleTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary, fontSize: 18),
        title: Text(lesson.name),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Container(
        constraints: const BoxConstraints(minWidth: 500.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 50.0),
                child: Text(
                  lesson.specificTips!,
                ),
              ),
              nextButton,
            ],
          ),
        ),
      ),
    );
  }
}
