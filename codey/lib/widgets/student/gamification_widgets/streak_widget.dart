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
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Text("Trenutni: ${user.streak}"),
                  Text("Najveći: ${user.highestStreak}"),
                ],
              ),
            ),
            Expanded(
              child: Icon(
                Icons.whatshot,
                color: user.streak > 0
                    ? Colors.red
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                size: 30.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
