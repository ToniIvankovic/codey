import 'package:codey/models/entities/app_user.dart';
import 'package:codey/widgets/student/gamification_widgets/leaderboard_widget.dart';
import 'package:codey/widgets/student/gamification_widgets/quests_widget.dart';
import 'package:codey/widgets/student/gamification_widgets/streak_widget.dart';
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        titleTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary, fontSize: 18),
        actionsIconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 60.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Card(
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
                StreakWidget(user: widget.user),
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
    );
  }
}
