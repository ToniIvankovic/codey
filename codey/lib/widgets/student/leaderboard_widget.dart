import 'package:codey/models/entities/leaderboard.dart';
import 'package:flutter/material.dart';

class LeaderboardWidget extends StatelessWidget {
  final Leaderboard leaderboard;
  const LeaderboardWidget({
    super.key,
    required this.leaderboard,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondary,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10.0),
              child: Text(
                "Leaderboard",
                style: TextStyle(fontSize: 18),
              ),
            ),
            for (var i = 0; i < leaderboard.students.length; i++)
              _generateLeaderboardRow(i),
          ],
        ),
      ),
    );
  }

  Widget _generateLeaderboardRow(int i) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
              "${i + 1}. ${leaderboard.students[i].firstName} ${leaderboard.students[i].lastName}:",
              overflow: TextOverflow.ellipsis),
        ),
        Text("${leaderboard.students[i].totalXp} XP",
            overflow: TextOverflow.visible),
        if (leaderboard.students[i].streak > 0)
          Text("Streak: ${leaderboard.students[i].streak}"),
      ],
    );
  }
}
