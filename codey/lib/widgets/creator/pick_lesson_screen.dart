import 'package:codey/models/entities/lesson.dart';
import 'package:codey/services/lessons_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PickLessonScreen extends StatefulWidget {
  const PickLessonScreen({super.key, this.existingLessons = const <Lesson>[]});
  final List<Lesson> existingLessons;

  @override
  State<PickLessonScreen> createState() => _PickLessonScreenState();
}

class _PickLessonScreenState extends State<PickLessonScreen> {
  @override
  Widget build(BuildContext context) {
    final lessonsService = context.read<LessonsService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick a lesson'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Text('Pick a lesson'),
            FutureBuilder(
                future: lessonsService.getAllLessons(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Lesson>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  final lessons = snapshot.data!;
                  lessons.removeWhere((lesson) => widget.existingLessons
                      .map((lesson) => lesson.id)
                      .contains(lesson.id));
                  return Expanded(
                    child: ListView.builder(
                      itemCount: lessons.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(
                              "${lessons[index].name} (${lessons[index].id})"),
                          onTap: () {
                            Navigator.pop(context, lessons[index]);
                          },
                        );
                      },
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }
}
