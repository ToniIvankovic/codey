import 'package:codey/models/entities/app_user.dart';
import 'package:codey/models/entities/leaderboard.dart';
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
  @override
  Widget build(BuildContext context) {
    if (leaderboard == null) {
      context
          .read<UserInteractionService>()
          .getLeaderboardStudent()
          .then((value) {
        setState(() {
          leaderboard = value;
        });
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("XP: ${widget.user.totalXp}"),
            const Text("Leaderboard"),
            if (leaderboard != null)
              for (var i = 0; i < leaderboard!.students.length; i++)
                Text(
                    "${i + 1}. ${leaderboard!.students[i].email} ${leaderboard!.students[i].totalXp}"),
            if(leaderboard == null)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
