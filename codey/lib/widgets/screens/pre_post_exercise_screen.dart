import 'package:codey/models/end_report.dart';
import 'package:codey/models/lesson.dart';
import 'package:codey/services/exercises_service.dart';
import 'package:codey/widgets/screens/exercises_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrePostExerciseScreen extends StatefulWidget {
  final Lesson lesson;

  const PrePostExerciseScreen({Key? key, required this.lesson})
      : super(key: key);

  @override
  State<PrePostExerciseScreen> createState() => _PrePostExerciseScreenState();
}

class _PrePostExerciseScreenState extends State<PrePostExerciseScreen> {
  bool completedSession = false;
  ExercisesService? exercisesService;

  @override
  Widget build(BuildContext context) {
    var exercisesService = context.read<ExercisesService>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      appBar: AppBar(
        title: Text(widget.lesson.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: completedSession != true
          ? Center(
              child: Column(
                children: [
                  Text(widget.lesson.specificTips ?? "No tips"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExercisesScreen(
                            lesson: widget.lesson,
                            onSessionCompleted: () {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                setState(() {
                                  completedSession = true;
                                });
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
            )
          : Center(
              child:
                  PostLessonReport(endReport: exercisesService.getEndReport()!),
            ),
    );
  }
}

class PostLessonReport extends StatelessWidget {
  const PostLessonReport({
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
            child: const Text('Go back'),
          ),
        ],
      ),
    );
  }
}
