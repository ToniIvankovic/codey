import 'package:codey/models/entities/lesson.dart';
import 'package:codey/services/lesson_groups_service.dart';
import 'package:codey/widgets/creator/lesson/pick_lesson_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateLessonGroup extends StatefulWidget {
  const CreateLessonGroup({
    super.key,
  });

  @override
  State<CreateLessonGroup> createState() => _CreateLessonGroupState();
}

class _CreateLessonGroupState extends State<CreateLessonGroup> {
  String? name;
  String? tips;
  List<Lesson> lessons = [];

  @override
  Widget build(BuildContext context) {
    bool inputValid = name != null && tips != null && lessons.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create lesson group"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) => setState(() => name = value),
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              onChanged: (value) => setState(() => tips = value),
              decoration: const InputDecoration(labelText: "Tips"),
              maxLines: 5,
              minLines: 2,
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Lessons", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            for (var lesson in lessons) ...[
              ListTile(
                title: Text(lesson.id.toString()),
                subtitle: Text(lesson.name),
                leading: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => lessons.remove(lesson)),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (context) => PickLessonScreen(
                                existingLessons: lessons,
                              ),
                            ),
                          )
                          .then(
                            (value) => setState(() {
                              if (value != null) {
                                lessons.add(value as Lesson);
                              }
                            }),
                          );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add lesson"),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: inputValid
                    ? () {
                        final lessonGroupsService =
                            context.read<LessonGroupsService>();
                        final lgr = lessonGroupsService.createLessonGroup(
                          name: name!,
                          tips: tips!,
                          lessons: lessons.map((e) => e.id).toList(),
                        );
                        Navigator.of(context).pop(lgr);
                      }
                    : null,
                child: const Text("Create"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
