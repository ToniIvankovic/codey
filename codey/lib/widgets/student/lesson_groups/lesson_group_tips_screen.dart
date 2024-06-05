import 'package:codey/models/entities/app_user.dart';
import 'package:codey/models/entities/lesson_group.dart';
import 'package:codey/util/rich_text_markdown.dart';
import 'package:codey/widgets/student/lessons/lessons_screen.dart';
import 'package:flutter/material.dart';

class LessonGroupTipsScreen extends StatelessWidget {
  final LessonGroup lessonGroup;
  final bool lessonGroupFinished;

  const LessonGroupTipsScreen({
    Key? key,
    required this.lessonGroup,
    required this.lessonGroupFinished,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lessonGroup.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 50),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichTextMarkdown(
                    text: lessonGroup.tips!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50.0),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Idi na lekcije'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
