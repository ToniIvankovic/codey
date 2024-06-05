import 'package:codey/models/entities/end_report.dart';
import 'package:codey/widgets/student/gamification_widgets/leaderboard_widget.dart';
import 'package:codey/widgets/student/gamification_widgets/quests_widget.dart';
import 'package:flutter/material.dart';

class PostLessonScreen extends StatelessWidget {
  const PostLessonScreen({
    super.key,
    required this.endReport,
    required this.awardedXP,
    required this.gamificationEnabled,
  });

  final EndReport endReport;
  final int? awardedXP;
  final bool gamificationEnabled;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gotovo!"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 800,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(18.0),
                  child:
                      Text("Lekcija završena!", style: TextStyle(fontSize: 18)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Column(
                    children: [
                      Container(
                        constraints: const BoxConstraints(
                          maxWidth: 250,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                    child: Text(
                                  "Točno / Ukupno:",
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
                                  "Preciznost:",
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
                                  "Vrijeme proteklo:",
                                  overflow: TextOverflow.ellipsis,
                                )),
                                Text(
                                  " ${endReport.duration.inMinutes}:${(endReport.duration.inSeconds % 60).toString().padLeft(2, '0')}",
                                ),
                              ],
                            ),
                            if (gamificationEnabled)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                      child: Text(
                                    "XP zarađeno:",
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
                      if (gamificationEnabled) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: QuestsWidget(),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: LeaderboardWidget(),
                        ),
                      ]
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text('Završi lekciju'),
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
