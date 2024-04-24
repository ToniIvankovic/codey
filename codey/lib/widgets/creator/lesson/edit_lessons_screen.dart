import 'package:codey/models/entities/lesson.dart';
import 'package:codey/services/lessons_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'create_lesson_screen.dart';
import 'edit_single_lesson_screen.dart';

class EditLessonsScreen extends StatefulWidget {
  const EditLessonsScreen({
    super.key,
  });

  @override
  State<EditLessonsScreen> createState() => _EditLessonsScreenState();
}

class _EditLessonsScreenState extends State<EditLessonsScreen> {
  List<Lesson> lessonsLocal = [];
  List<Lesson> lessonsToDelete = [];
  int? expandedId;

  @override
  Widget build(BuildContext context) {
    if (lessonsLocal.isEmpty) {
      LessonsService lessonsService = context.read<LessonsService>();
      lessonsService.getAllLessons().then((value) => setState(() {
            lessonsLocal = List.of(value);
          }));
    }
    final bool madeChanges = lessonsToDelete.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit lessons'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ListView(
              shrinkWrap: true,
              children: <Widget>[
                for (Lesson lesson in lessonsLocal)
                  ListTile(
                    title: Text('${lesson.name} (${lesson.id})'),
                    subtitle: expandedId == lesson.id
                        ? Text("Exercises: ${lesson.exerciseIds.join(", ")}")
                        : null,
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              lessonsLocal.remove(lesson);
                              lessonsToDelete.add(lesson);
                              lessonsToDelete
                                  .sort((a, b) => a.id.compareTo(b.id));
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                  builder: (context) =>
                                      EditSingleLessonScreen(lesson),
                                ))
                                .then(
                                  (value) => {
                                    setState(() {
                                      lessonsLocal.clear();
                                      lessonsToDelete.clear();
                                    }),
                                  },
                                );
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        expandedId = expandedId == lesson.id ? null : lesson.id;
                      });
                    },
                  ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        Navigator.of(context)
                            .push(
                          MaterialPageRoute(
                            builder: (context) => const CreateLessonScreen(),
                          ),
                        )
                            .then((value) {
                          if (value != null) {
                            setState(() {
                              lessonsLocal.add(value);
                            });
                          }
                        });
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add new lesson'),
                  ),
                ),
              ],
            ),
            if (lessonsToDelete.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Lessons to delete: "
                    "${lessonsToDelete.map((e) => e.id.toString()).toList().join(", ")}"),
              ),
            // COMMIT CHANGES TO BE
            ElevatedButton(
              onPressed: madeChanges
                  ? () {
                      for (Lesson lesson in lessonsToDelete) {
                        context.read<LessonsService>().deleteLesson(lesson);
                      }
                      Navigator.of(context).pop();
                    }
                  : null,
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}
