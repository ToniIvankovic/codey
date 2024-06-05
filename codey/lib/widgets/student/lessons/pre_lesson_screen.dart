import 'package:codey/models/entities/app_user.dart';
import 'package:codey/models/entities/lesson.dart';
import 'package:codey/models/entities/lesson_group.dart';
import 'package:codey/widgets/student/exercises/exercises_screen.dart';
import 'package:flutter/material.dart';

import '../../../util/rich_text_markdown.dart';

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
    var nextButton = ElevatedButton.icon(
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
        titleTextStyle: const TextStyle(fontSize: 18),
        title: Text(lesson.name),
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Container(
            constraints: const BoxConstraints(minWidth: 500.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 50.0),
                    child: RichTextMarkdown(
                      text: lesson.specificTips!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  nextButton,
                  const SizedBox(height: 50.0)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
