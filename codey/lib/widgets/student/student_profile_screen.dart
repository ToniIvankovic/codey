import 'package:codey/models/entities/app_user.dart';
import 'package:codey/models/entities/leaderboard.dart';
import 'package:codey/models/entities/quest.dart';
import 'package:codey/services/user_interaction_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentProfileScreen extends StatefulWidget {
  final AppUser user;
  const StudentProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  Leaderboard? leaderboard;
  bool leaderboardLoading = false;

  @override
  void initState() {
    super.initState();
    context
        .read<UserInteractionService>()
        .getLeaderboardStudent()
        .then((value) {
      setState(() {
        leaderboard = value;
        leaderboardLoading = false;
      });
    }).catchError((onError) {
      setState(() {
        leaderboard = null;
        leaderboardLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("XP: ${widget.user.totalXp}"),
            Text("Highest streak: ${widget.user.highestStreak}"),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              child: Column(
                children: [
                  const Text("Quests:"),
                  for (var quest in widget.user.quests)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _generateQuestWidget(quest),
                        if (quest.isCompleted)
                          const Icon(Icons.check_box)
                        else
                          const Icon(Icons.check_box_outline_blank),
                      ],
                    ),
                ],
              ),
            ),
            if (leaderboardLoading) ...[
              const Text("Leaderboard"),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              )
            ] else if (leaderboard != null) ...[
              const Text("Leaderboard"),
              for (var i = 0; i < leaderboard!.students.length; i++)
                Text(
                    "${i + 1}. ${leaderboard!.students[i].email} ${leaderboard!.students[i].totalXp}"),
            ]
          ],
        ),
      ),
    );
  }

  Widget _generateQuestWidget(Quest quest) {
    switch (quest.type) {
      case Quest.questGetXp:
        return Text(
            "Get ${quest.constraint} XP: ${quest.progress}/${quest.constraint}");
      case Quest.questHighAccuracy:
        return Text(
            "High accuracy (>${quest.constraint}%): ${quest.progress}/${quest.nLessons}");
      case Quest.questHighSpeed:
        return Text(
            "High speed (<${quest.constraint}s): ${quest.progress}/${quest.nLessons}");
      case Quest.questCompleteLessonGroup:
        return const Text("Complete a lesson group");
      default:
        return const Text("Unknown quest");
    }
  }
}
