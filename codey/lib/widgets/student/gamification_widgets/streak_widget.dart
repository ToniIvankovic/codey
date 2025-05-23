import 'package:codey/models/entities/app_user.dart';
import 'package:flutter/material.dart';

class StreakWidget extends StatelessWidget {
  final AppUser user;
  const StreakWidget({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 10.0),
          child: Text("Streak", style: TextStyle(fontSize: 18)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.whatshot,
              color: user.didLessonToday
                  ? Colors.red
                  : Theme.of(context).colorScheme.onInverseSurface.withOpacity(0.5),
              size: 30.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Text("Trenutni: ${user.streak}"),
                  Text("Najveći: ${user.highestStreak}"),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
