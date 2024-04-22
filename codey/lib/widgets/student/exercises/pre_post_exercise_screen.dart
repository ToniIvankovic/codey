import 'package:codey/models/entities/end_report.dart';
import 'package:codey/models/entities/leaderboard.dart';
import 'package:codey/models/entities/lesson.dart';
import 'package:codey/models/entities/lesson_group.dart';
import 'package:codey/services/exercises_service.dart';
import 'package:codey/services/user_interaction_service.dart';
import 'package:codey/widgets/student/exercises/exercises_screen.dart';
import 'package:codey/widgets/student/leaderboard_widget.dart';
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
      body: completedLesson == false
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
                (awardedXP) {
                  setAwardedXP(awardedXP);
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

class _PostLessonReport extends StatefulWidget {
  const _PostLessonReport({
    required this.endReport,
    required this.awardedXP,
  });

  final EndReport endReport;
  final int? awardedXP;

  @override
  State<_PostLessonReport> createState() => _PostLessonReportState();
}

class _PostLessonReportState extends State<_PostLessonReport> {
  Leaderboard? leaderboard;
  bool leaderboardLoading = false;

  @override
  void initState() {
    super.initState();
    leaderboardLoading = true;
    context
        .read<UserInteractionService>()
        .getLeaderboardStudent()
        .then((value) {
      setState(() {
        leaderboard = value;
        leaderboardLoading = false;
      });
    }).catchError(
      (error) {
        //User not in class
        setState(() {
          leaderboard = null;
          leaderboardLoading = false;
        });
      },
    );
  }

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
            padding: const EdgeInsets.symmetric(horizontal: 100.0),
            child: Column(
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Correct / Total:"),
                        Text(
                            "${widget.endReport.correctAnswers}/${widget.endReport.totalAnswers}"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Accuracy:"),
                        Text(" ${(widget.endReport.accuracy * 100).toInt()}%"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Time taken:"),
                        Text(
                          " ${widget.endReport.duration.inMinutes}:${(widget.endReport.duration.inSeconds % 60).toString().padLeft(2, '0')}",
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("XP achieved:"),
                        widget.awardedXP != null
                            ? Text(widget.awardedXP.toString())
                            : const CircularProgressIndicator(),
                      ],
                    ),
                    if (leaderboardLoading) ...[
                      const Text("Leaderboard:"),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    ],
                    if (leaderboard != null)
                      LeaderboardWidget(leaderboard: leaderboard!),
                  ],
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
