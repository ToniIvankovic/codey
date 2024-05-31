import 'package:codey/models/entities/leaderboard.dart';
import 'package:codey/services/user_interaction_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LeaderboardWidget extends StatefulWidget {
  const LeaderboardWidget({
    super.key,
  });

  @override
  State<LeaderboardWidget> createState() => _LeaderboardWidgetState();
}

class _LeaderboardWidgetState extends State<LeaderboardWidget> {
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
      if (!mounted) {
        return;
      }
      setState(() {
        leaderboard = value;
        leaderboardLoading = false;
      });
    }).catchError((onError) {
      if (!mounted) {
        return;
      }
      setState(() {
        leaderboard = null;
        leaderboardLoading = false;
      });
    });
  }

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
                "Ljestvica poretka",
                style: TextStyle(fontSize: 18),
              ),
            ),
            if (leaderboardLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                  ],
                ),
              )
            else if (!leaderboardLoading && leaderboard == null)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Nema ljestvice poretka"),
              )
            else
              for (var i = 0; i < leaderboard!.students.length; i++)
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
              "${i + 1}. ${leaderboard!.students[i].firstName} ${leaderboard!.students[i].lastName}:",
              overflow: TextOverflow.ellipsis),
        ),
        if (leaderboard!.students[i].streak > 0) ...[
          Text("${leaderboard!.students[i].streak}"),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: Icon(Icons.whatshot, color: Colors.red, size: 20.0),
          ),
        ],
        Text("${leaderboard!.students[i].totalXp} XP",
            overflow: TextOverflow.visible),
      ],
    );
  }
}
