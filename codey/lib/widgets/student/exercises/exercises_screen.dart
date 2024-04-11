import 'package:codey/models/entities/lesson.dart';
import 'package:codey/models/entities/lesson_group.dart';
import 'package:codey/services/exercises_service.dart';
import 'package:codey/widgets/student/exercises/single_exercise_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExercisesScreen extends StatelessWidget {
  final Lesson lesson;
  final LessonGroup lessonGroup;
  final VoidCallback onSessionCompleted;

  const ExercisesScreen({
    super.key,
    required this.lesson,
    required this.lessonGroup,
    required this.onSessionCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final exercisesService = context.read<ExercisesService>();
    final Future<void> startSessionFuture =
        exercisesService.startSessionForLesson(lesson, lessonGroup);

    return WillPopScope(
      onWillPop: () async {
        if (exercisesService.sessionActive) {
          exercisesService.endSession(false);
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        appBar: AppBar(
          title: Text('Lesson: ${lesson.name}'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
          child: FutureBuilder<void>(
            future: startSessionFuture,
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(
                  strokeWidth: 5,
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              var exercise = exercisesService.getNextExercise();
              if (exercise == null) {
                return const Text('No exercises');
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SingleExerciseWidget(
                    key: ValueKey(exercise.id),
                    exercisesService: exercisesService,
                    onSessionFinished: () => {
                      exercisesService.endSession(true),
                      onSessionCompleted(),
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.pop(context);
                      })
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
