import 'package:codey/models/entities/app_user.dart';
import 'package:codey/models/entities/exercise.dart';
import 'package:codey/models/entities/lesson.dart';
import 'package:codey/models/entities/lesson_group.dart';
import 'package:codey/services/exercises_service.dart';
import 'package:codey/widgets/student/exercises/post_lesson_screen.dart';
import 'package:codey/widgets/student/exercises/single_exercise_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExercisesScreen extends StatefulWidget {
  final Lesson lesson;
  final LessonGroup lessonGroup;
  final AppUser user;

  const ExercisesScreen({
    super.key,
    required this.lesson,
    required this.lessonGroup,
    required this.user,
  });

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  Exercise? currentExercise;
  @override
  void initState() {
    super.initState();
    final exercisesService = context.read<ExercisesService>();
    exercisesService
        .startSessionForLesson(widget.lesson, widget.lessonGroup)
        .then((value) {
      setState(() {
        currentExercise = exercisesService.getNextExercise();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final exercisesService = context.read<ExercisesService>();
    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Izlazak'),
              content: const Text(
                  'Želiš li sigurno izići iz lekcije? Riješene vježbe bit će izgubljene.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Ne, ostani u lekciji'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Da, iziđi'),
                ),
              ],
            );
          },
        ).then((value) {
          if (value == true) {
            if (exercisesService.sessionActive) {
              exercisesService.endSession(false);
            }
            return true;
          }
          return false;
        });
      },
      child: Scaffold(
        appBar: AppBar(
          titleTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary, fontSize: 18),
          title: Text('Lekcija: ${widget.lesson.name}'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
          child: currentExercise == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                    ],
                  ),
                )
              : Container(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.of(context).size.height - kToolbarHeight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: SingleExerciseWidget(
                          key: ValueKey(currentExercise!.id),
                          exercisesService: exercisesService,
                          onSessionFinished: () async {
                            int? awardedXP =
                                await exercisesService.endSession(true);
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (context) {
                                return PostLessonScreen(
                                  endReport: exercisesService.getEndReport()!,
                                  awardedXP: awardedXP,
                                  gamificationEnabled: widget.user.gamificationEnabled,
                                );
                              }));
                            });
                          },
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
