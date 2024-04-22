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

  @override
  void initState() {
    super.initState();
    var user$ = context.read<UserService>().userStream;
    user$.listen((user) {
      setState(() {
        quests = user.quests;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 10.0),
          child: Text(
            "Ciljevi:",
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
            Text(
              "Osvoji ${quest.constraint} XP: ",
              overflow: TextOverflow.ellipsis,
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
        return Text(
          "Visoka preciznost (>${quest.constraint}%): ${quest.progress}/${quest.nLessons}",
          overflow: TextOverflow.ellipsis,
        );
      case Quest.questHighSpeed:
        return Text(
          "Velika brzina (<${quest.constraint}s): ${quest.progress}/${quest.nLessons}",
          overflow: TextOverflow.ellipsis,
        );
      case Quest.questCompleteLessonGroup:
        return const Text(
          "Dovrši cjelinu",
          overflow: TextOverflow.ellipsis,
        );
      default:
        return const Text(
          "Nepoznat cilj",
          overflow: TextOverflow.ellipsis,
        );
    }
  }
}
