import 'package:codey/models/entities/lesson_group.dart';
import 'package:codey/services/lesson_groups_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'create_lesson_group_screen.dart';
import 'edit_single_lesson_group_screen.dart';

class EditLessonGroupsScreen extends StatefulWidget {
  const EditLessonGroupsScreen({
    super.key,
  });

  @override
  State<EditLessonGroupsScreen> createState() => _EditLessonGroupsScreenState();
}

class _EditLessonGroupsScreenState extends State<EditLessonGroupsScreen> {
  List<LessonGroup>? lessonGroupsInitial;
  List<LessonGroup>? lessonGroupsLocal;
  List<LessonGroup> lessonGroupsToDelete = [];
  int? expandedId;

  @override
  Widget build(BuildContext context) {
    if (lessonGroupsLocal == null) {
      final lessonGroupsService = context.read<LessonGroupsService>();
      lessonGroupsService.getAllLessonGroups().then((value) => setState(
            () => {
              lessonGroupsInitial = List.of(value),
              lessonGroupsLocal = List.of(value),
            },
          ));
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    final bool isChanged = !listEquals(lessonGroupsLocal, lessonGroupsInitial);

    var reorderableListView = ReorderableListView(
      shrinkWrap: true,
      onReorder: (int oldIndex, int newIndex) {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        setState(() {
          lessonGroupsLocal!.insert(
            newIndex,
            lessonGroupsLocal!.removeAt(oldIndex),
          );
        });
      },
      children: <Widget>[
        for (var lessonGroup in lessonGroupsLocal!) ...[
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.of(context)
                            .push(
                          MaterialPageRoute(
                            builder: (context) => EditSingleLessonGroupScreen(
                              lessonGroup: lessonGroup,
                            ),
                          ),
                        )
                            .then(
                          (value) {
                            if (value == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("No changes made"),
                                ),
                              );
                              return;
                            }
                            setState(() {
                              lessonGroupsLocal![lessonGroupsLocal!.indexWhere(
                                      (element) =>
                                          element.id == lessonGroup.id)] =
                                  value as LessonGroup;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Lesson group updated"),
                              ),
                            );
                          },
                        );
                      }),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        lessonGroupsLocal!.remove(lessonGroup);
                        lessonGroupsToDelete.add(lessonGroup);
                      });
                    },
                  ),
                ],
              ),
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
        title: const Text('Edit lesson groups'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          reorderableListView,
          //add lesson group
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 30.0, vertical: 10.0),
                child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (context) => const CreateLessonGroup(),
                            ),
                          )
                          .then(
                            (value) => setState(() {
                              if (value != null) {
                                lessonGroupsLocal!.add(value as LessonGroup);
                                lessonGroupsInitial!.add(value);
                              }
                            }),
                          );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add lesson group")),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: ElevatedButton(
              onPressed: isChanged
                  ? () {
                      final lessonGroupsService =
                          context.read<LessonGroupsService>();
                      lessonGroupsService
                          .reorderLessonGroups(lessonGroupsLocal!);
                      for (var lessonGroup in lessonGroupsToDelete) {
                        lessonGroupsService
                            .deleteLessonGroup(lessonGroup.id)
                            .then((value) => setState(() {
                                  lessonGroupsLocal!.remove(lessonGroup);
                                }));
                      }
                      Navigator.pop(context);
                    }
                  : null,
              child: const Text("Save"),
            ),
          ),
        ],
      ),
    );
  }
}
