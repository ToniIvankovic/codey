import 'package:codey/exercises_screen.dart';
import 'package:codey/models/lesson.dart';
import 'package:codey/models/lesson_group.dart';
import 'package:codey/repositories/lessons_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Replace with the actual path

class LessonsScreen extends StatelessWidget {
  final LessonGroup lessonGroup; // Inject the LessonsRepository

  const LessonsScreen({
    Key? key,
    required this.lessonGroup,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LessonsRepository lessonsRepository =
        Provider.of<LessonsRepository>(context);
    Future<List<Lesson>> lessonsFuture =
        lessonsRepository.getLessonsForGroup(lessonGroup.id.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text(lessonGroup.name), // Set the title of the lessonGroup
      ),
      body: FutureBuilder<List<Lesson>>(
        future: lessonsFuture,
        builder: (BuildContext context, AsyncSnapshot<List<Lesson>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(
              strokeWidth: 5,
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.data == null) {
            return const Text('No data');
          } else {
            var lessons = snapshot.data!;
            return ListView.builder(
              itemCount: lessons.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text('${lessons[index].id} ${lessons[index].name}'),
                  subtitle: ButtonBar(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExercisesScreen(
                                lesson: lessons[index],
                              ),
                            ),
                          );
                        },
                        child: const Text('Exercises'),
                      ),
                    ],
                  )
                );
              },
            );
          }
        },
      ),
    );
  }
}
