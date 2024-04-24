import 'dart:async';

import 'package:codey/models/entities/app_user.dart';
import 'package:codey/models/entities/quest.dart';
import 'package:codey/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuestsWidget extends StatefulWidget {
  const QuestsWidget({
    super.key,
  });

  @override
  State<QuestsWidget> createState() => _QuestsWidgetState();
}

class _QuestsWidgetState extends State<QuestsWidget> {
  Set<Quest>? quests;
  late final StreamSubscription<AppUser> subscription;

  @override
  void initState() {
    super.initState();
    var user$ = context.read<UserService>().userStream;
    subscription = user$.listen((user) {
      setState(() {
        quests = user.quests;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 10.0),
          child: Text(
            "Dnevni Ciljevi:",
            style: TextStyle(fontSize: 18),
          ),
        ),
        if (quests == null)
          const CircularProgressIndicator()
        else
          for (var quest in quests!)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _generateQuestText(quest)),
                if (quest.isCompleted)
                  const Icon(Icons.check_box)
                else
                  const Icon(Icons.check_box_outline_blank),
              ],
            ),
      ],
    );
  }

  Widget _generateQuestText(Quest quest) {
    switch (quest.type) {
      case Quest.questGetXp:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.star_border),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Osvoji ${quest.constraint} XP: ",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (!quest.isCompleted)
              Expanded(
                child: Text(
                  "${quest.progress}/${quest.constraint}",
                  textAlign: TextAlign.right,
                ),
              ),
          ],
        );
      case Quest.questHighAccuracy:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.track_changes),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Visoka preciznost (>${quest.constraint}%):",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (!quest.isCompleted)
              Expanded(
                child: Text(
                  "${quest.progress}/${quest.nLessons}",
                  textAlign: TextAlign.right,
                ),
              ),
          ],
        );
      case Quest.questHighSpeed:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.speed),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Velika brzina (<${quest.constraint}s):",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (!quest.isCompleted)
              Expanded(
                child: Text(
                  "${quest.progress}/${quest.nLessons}",
                  textAlign: TextAlign.right,
                ),
              ),
          ],
        );
      case Quest.questCompleteLessonGroup:
        return const Row(
          children: [
            Icon(Icons.check_circle_outline),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Dovrši cjelinu",
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      default:
        return const Text(
          "Nepoznat cilj",
          overflow: TextOverflow.ellipsis,
        );
    }
  }
}
