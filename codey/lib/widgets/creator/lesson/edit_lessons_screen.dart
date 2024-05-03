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
  int? expandedId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    LessonsService lessonsService = context.read<LessonsService>();
    lessonsService.getAllLessons().then((value) => setState(() {
          lessonsLocal = List.of(value);
          lessonsLocal.sort((a, b) => -a.id.compareTo(b.id));
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit lessons'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
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
                              lessonsLocal.insert(0, value);
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
                            //popups a dialog to confirm deletion
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Delete lesson"),
                                  content: Text(
                                      "Are you sure you want to delete lesson ${lesson.name} (${lesson.id})?"),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        setState(() {
                                          lessonsLocal.remove(lesson);
                                          context
                                              .read<LessonsService>()
                                              .deleteLesson(lesson);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Lesson ${lesson.id} deleted successfully'),
                                            ),
                                          );
                                        });
                                      },
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                );
                              },
                            );
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
                              (value) {
                                if (value == null) return;
                                setState(() {
                                  lessonsLocal[lessonsLocal.indexWhere(
                                      (element) =>
                                          element.id == lesson.id)] = value;
                                });
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
          ],
        ),
      ),
    );
  }
}
