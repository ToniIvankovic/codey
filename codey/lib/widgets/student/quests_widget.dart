import 'package:codey/models/entities/quest.dart';
import 'package:flutter/material.dart';

class QuestsWidget extends StatelessWidget {
  final Set<Quest> quests;
  const QuestsWidget({
    super.key,
    required this.quests,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 10.0),
          child: Text(
            "Quests:",
            style: TextStyle(fontSize: 18),
          ),
        ),
        for (var quest in quests)
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
            Text(
              "Get ${quest.constraint} XP: ",
              overflow: TextOverflow.ellipsis,
            ),
            Expanded(
                child: Text(
              "${quest.progress}/${quest.constraint}",
              textAlign: TextAlign.right,
            ))
          ],
        );
      case Quest.questHighAccuracy:
        return Text(
          "High accuracy (>${quest.constraint}%): ${quest.progress}/${quest.nLessons}",
          overflow: TextOverflow.ellipsis,
        );
      case Quest.questHighSpeed:
        return Text(
          "High speed (<${quest.constraint}s): ${quest.progress}/${quest.nLessons}",
          overflow: TextOverflow.ellipsis,
        );
      case Quest.questCompleteLessonGroup:
        return const Text(
          "Complete a lesson group",
          overflow: TextOverflow.ellipsis,
        );
      default:
        return const Text(
          "Unknown quest",
          overflow: TextOverflow.ellipsis,
        );
    }
  }
}
