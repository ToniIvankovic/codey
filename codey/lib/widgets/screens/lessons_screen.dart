import 'package:codey/models/entities/app_user.dart';
import 'package:codey/models/entities/lesson.dart';
import 'package:codey/models/entities/lesson_group.dart';
import 'package:codey/repositories/lessons_repository.dart';
import 'package:codey/services/user_service.dart';
import 'package:codey/widgets/screens/pre_post_exercise_screen.dart';
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
    Stream<AppUser?> user$ = context.read<UserService>().userStream;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      appBar: AppBar(
        title: Text(lessonGroup.name),
        backgroundColor: Theme.of(context)
            .colorScheme
            .inversePrimary, // Set the title of the lessonGroup
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

            return StreamBuilder<AppUser?>(
              stream: user$,
              builder:
                  (BuildContext context, AsyncSnapshot<AppUser?> userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(
                    strokeWidth: 5,
                  );
                } else if (userSnapshot.hasError) {
                  return Text('Error: ${userSnapshot.error}');
                } else if (userSnapshot.data == null) {
                  return const Text('No user data');
                } else {
                  AppUser user = userSnapshot.data!;
                  return ListView.builder(
                    itemCount: lessons.length,
                    itemBuilder: (BuildContext context, int index) {
                      var lesson = lessons[index];
                      bool isClickable = lesson.id <= user.nextLessonId;
                      return ListTile(
                        title: Text('${lesson.id} ${lesson.name}'),
                        subtitle: ButtonBar(
                          children: [
                            TextButton(
                              onPressed: isClickable
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PrePostExerciseScreen(
                                            lesson: lesson,
                                          ),
                                        ),
                                      );
                                    }
                                  : () {},
                              child: Text('Play',
                                  style: TextStyle(
                                    color: isClickable
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                  )),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
