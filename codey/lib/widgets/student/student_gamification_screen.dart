import 'package:codey/models/entities/app_user.dart';
import 'package:codey/widgets/student/gamification_widgets/leaderboard_widget.dart';
import 'package:codey/widgets/student/gamification_widgets/quests_widget.dart';
import 'package:codey/widgets/student/gamification_widgets/streak_widget.dart';
import 'package:flutter/material.dart';

class StudentGamificationScreen extends StatefulWidget {
  final AppUser user;
  const StudentGamificationScreen({
    super.key,
    required this.user,
  });

  @override
  State<StudentGamificationScreen> createState() => _StudentGamificationScreenState();
}

class _StudentGamificationScreenState extends State<StudentGamificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Postignuća'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        titleTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary, fontSize: 18),
        actionsIconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 60.0, vertical: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Card(
                      color: Theme.of(context).colorScheme.secondary,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("XP: ${widget.user.totalXp}",
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: StreakWidget(user: widget.user),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18.0),
                    child: QuestsWidget(),
                  ),
                  const LeaderboardWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
