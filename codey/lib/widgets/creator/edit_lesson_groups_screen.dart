import 'package:codey/models/entities/lesson_group.dart';
import 'package:codey/services/lesson_groups_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'edit_single_lesson_group_screen.dart';

class EditLessonGroupsScreen extends StatefulWidget {
  const EditLessonGroupsScreen({
    super.key,
  });

  @override
  State<EditLessonGroupsScreen> createState() => _EditLessonGroupsScreenState();
}

class _EditLessonGroupsScreenState extends State<EditLessonGroupsScreen> {
  List<LessonGroup>? lessonGroups;
  int? expandedId;

  @override
  Widget build(BuildContext context) {
    if (lessonGroups == null) {
      final lessonGroupsService = context.read<LessonGroupsService>();
      lessonGroupsService
          .getAllLessonGroups()
          .then((value) => setState(() => lessonGroups = value));
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    var reorderableListView = ReorderableListView(
      onReorder: (int oldIndex, int newIndex) {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        print("$oldIndex, $newIndex");
        setState(() {
          lessonGroups!.insert(
            newIndex,
            lessonGroups!.removeAt(oldIndex),
          );
        });
      },
      children: <Widget>[
        for (var lessonGroup in lessonGroups!) ...[
          ListTile(
            key: ValueKey(lessonGroup.id),
            title: Text("${lessonGroup.name} (${lessonGroup.id})"),
            onTap: () => {
              if (expandedId == lessonGroup.id)
                setState(() {
                  expandedId = null;
                })
              else
                setState(() {
                  expandedId = lessonGroup.id;
                })
            },
            leading: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    print("Edit lesson group ${lessonGroup.id}");
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (context) => EditSingleLessonGroupScreen(
                              lessonGroup: lessonGroup,
                            ),
                          ),
                        )
                        .then(
                          (value) => setState(() {}),
                        );
                  }),
            ),
            isThreeLine: expandedId == lessonGroup.id,
            subtitle: expandedId == lessonGroup.id
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Lessons: ${lessonGroup.lessons.map((e) => e.toString()).join(", ")}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        lessonGroup.tips,
                        maxLines: 10,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  )
                : null,
          ),
        ]
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit all'),
      ),
      body: Column(
        children: [
          Expanded(child: reorderableListView),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: ElevatedButton(
              onPressed: () {
                final lessonGroupsService = context.read<LessonGroupsService>();
                lessonGroupsService.reorderLessonGroups(lessonGroups!);
              },
              child: const Text("Save"),
            ),
          ),
        ],
      ),
    );
  }
}
