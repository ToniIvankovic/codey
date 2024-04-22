import 'package:codey/models/entities/end_report.dart';
import 'package:codey/models/entities/lesson.dart';
import 'package:codey/models/entities/lesson_group.dart';
import 'package:codey/services/exercises_service.dart';
import 'package:codey/widgets/student/exercises/exercises_screen.dart';
import 'package:codey/widgets/student/gamification_widgets/leaderboard_widget.dart';
import 'package:codey/widgets/student/gamification_widgets/quests_widget.dart';
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
  int? awardedXP;

  @override
  Widget build(BuildContext context) {
    final exercisesService = context.read<ExercisesService>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        titleTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary, fontSize: 18),
        title: Text(widget.lesson.name),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Container(
        constraints: const BoxConstraints(minWidth: 500.0),
        child: completedLesson == false
            ? _PreLessonReport(
                lesson: widget.lesson,
                lessonGroup: widget.lessonGroup,
                postLessonCallback: () {
                  setState(() {
                    completedLesson = true;
                  });
                },
                setAwardedXP: (int xp) {
                  setState(() {
                    awardedXP = xp;
                  });
                },
              )
            : _PostLessonReport(
                endReport: exercisesService.getEndReport()!,
                awardedXP: awardedXP,
              ),
      ),
    );
  }
}

class _PreLessonReport extends StatelessWidget {
  final Lesson lesson;
  final LessonGroup lessonGroup;
  final VoidCallback postLessonCallback;
  final Function(int) setAwardedXP;

  const _PreLessonReport({
    Key? key,
    required this.lesson,
    required this.lessonGroup,
    required this.postLessonCallback,
    required this.setAwardedXP,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
                lesson.specificTips ?? "No tips for this lesson, good luck!"),
          ),
          TextButton.icon(
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
              ).then(
                (value) {
                  if (value == null) return;
                  setAwardedXP(value);
                },
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Lesson'),
          ),
        ],
      ),
    );
  }
}

class _PostLessonReport extends StatelessWidget {
  const _PostLessonReport({
    required this.endReport,
    required this.awardedXP,
  });

  final EndReport endReport;
  final int? awardedXP;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(18.0),
            child: Text("Lesson completed!", style: TextStyle(fontSize: 18)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                              child: Text(
                            "Correct / Total:",
                            overflow: TextOverflow.ellipsis,
                          )),
                          Text(
                              "${endReport.correctAnswers}/${endReport.totalAnswers}"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                              child: Text(
                            "Accuracy:",
                            overflow: TextOverflow.ellipsis,
                          )),
                          Text(" ${(endReport.accuracy * 100).toInt()}%"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                              child: Text(
                            "Time taken:",
                            overflow: TextOverflow.ellipsis,
                          )),
                          Text(
                            " ${endReport.duration.inMinutes}:${(endReport.duration.inSeconds % 60).toString().padLeft(2, '0')}",
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                              child: Text(
                            "XP achieved:",
                            overflow: TextOverflow.ellipsis,
                          )),
                          awardedXP != null
                              ? Text(awardedXP.toString())
                              : const CircularProgressIndicator(),
                        ],
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: LeaderboardWidget(),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: QuestsWidget(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Finish'),
            ),
          ),
        ],
      ),
    );
  }
}
