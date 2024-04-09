import 'package:codey/models/entities/app_user.dart';
import 'package:codey/models/entities/lesson.dart';
import 'package:codey/models/entities/lesson_group.dart';
import 'package:codey/services/lessons_service.dart';
import 'package:codey/services/user_service.dart';
import 'package:codey/widgets/exercises/pre_post_exercise_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LessonsScreen extends StatelessWidget {
  final LessonGroup lessonGroup;

  const LessonsScreen({
    Key? key,
    required this.lessonGroup,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LessonsService lessonsService = Provider.of<LessonsService>(context);
    Future<List<Lesson>> lessonsFuture =
        lessonsService.getLessonsForGroup(lessonGroup);
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
                      bool isClickable;
                      // Lesson group not already solved
                      if (lessonGroup.lessons.contains(user.nextLessonId)) {
                        isClickable = lessonGroup.lessons.indexOf(lesson.id) <=
                            lessonGroup.lessons.indexOf(user.nextLessonId ?? 0);
                      } else {
                        isClickable = true;
                      }
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
                                            lessonGroup: lessonGroup,
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
