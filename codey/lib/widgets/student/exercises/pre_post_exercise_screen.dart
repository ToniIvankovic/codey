import 'package:codey/models/entities/end_report.dart';
import 'package:codey/models/entities/lesson.dart';
import 'package:codey/models/entities/lesson_group.dart';
import 'package:codey/services/exercises_service.dart';
import 'package:codey/widgets/student/exercises/exercises_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrePostExerciseScreen extends StatefulWidget {
  final Lesson lesson;
  final LessonGroup lessonGroup;

  const PrePostExerciseScreen({
    Key? key,
    required this.lesson,
    required this.lessonGroup,
  }) : super(key: key);

  @override
  State<PrePostExerciseScreen> createState() => _PrePostExerciseScreenState();
}

class _PrePostExerciseScreenState extends State<PrePostExerciseScreen> {
  bool completedLesson = false;
  ExercisesService? exercisesService;

  @override
  Widget build(BuildContext context) {
    final exercisesService = context.read<ExercisesService>();

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        appBar: AppBar(
          title: Text(widget.lesson.name),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: completedLesson == false
            ? _PreLessonReport(
                lesson: widget.lesson,
                lessonGroup: widget.lessonGroup,
                postLessonCallback: () {
                  setState(() {
                    completedLesson = true;
                  });
                },
              )
            : _PostLessonReport(endReport: exercisesService.getEndReport()!));
  }
}

class _PreLessonReport extends StatelessWidget {
  final Lesson lesson;
  final LessonGroup lessonGroup;
  final VoidCallback postLessonCallback;

  const _PreLessonReport({
    Key? key,
    required this.lesson,
    required this.lessonGroup,
    required this.postLessonCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(lesson.specificTips ?? "No tips"),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExercisesScreen(
                    lesson: lesson,
                    lessonGroup: lessonGroup,
                    onSessionCompleted: () {
                      // The callback is delayed to after drawing is finished
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        postLessonCallback();
                      });
                    },
                  ),
                ),
              );
            },
            child: const Text('Start Lesson'),
          ),
        ],
      ),
    );
  }
}

class _PostLessonReport extends StatelessWidget {
  const _PostLessonReport({
    Key? key,
    required this.endReport,
  }) : super(key: key);

  final EndReport endReport;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text("Lesson completed!"),
          Text(
              "You got ${endReport.correctAnswers} out of ${endReport.totalAnswers} correct!"),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }
}
