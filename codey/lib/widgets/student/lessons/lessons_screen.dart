import 'package:codey/models/entities/app_user.dart';
import 'package:codey/models/entities/lesson.dart';
import 'package:codey/models/entities/lesson_group.dart';
import 'package:codey/services/lessons_service.dart';
import 'package:codey/services/user_service.dart';
import 'package:codey/widgets/student/exercises/pre_post_exercise_screen.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LessonsScreen extends StatefulWidget {
  final LessonGroup lessonGroup;
  final bool lessonGroupFinished;

  const LessonsScreen({
    super.key,
    required this.lessonGroup,
    required this.lessonGroupFinished,
  });

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  bool lessonGroupFinished = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    lessonGroupFinished = widget.lessonGroupFinished;
  }

  @override
  Widget build(BuildContext context) {
    LessonsService lessonsService = Provider.of<LessonsService>(context);
    Future<List<Lesson>> lessonsFuture =
        lessonsService.getLessonsForGroup(widget.lessonGroup);
    Stream<AppUser?> user$ = context.read<UserService>().userStream;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.lessonGroup.name,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context)
            .colorScheme
            .primary, // Set the title of the lessonGroup
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
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
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50.0, vertical: 15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: lessons.length,
                          itemBuilder: (BuildContext context, int index) {
                            var lesson = lessons[index];
                            bool isClickable;
                            // Lesson group not already solved
                            if (!lessonGroupFinished) {
                              isClickable = widget.lessonGroup.lessons
                                      .indexOf(lesson.id) <=
                                  widget.lessonGroup.lessons
                                      .indexOf(user.nextLessonId ?? 0);
                            } else {
                              isClickable = true;
                            }
                            return DottedBorder(
                              color: lesson.id == user.nextLessonId &&
                                      !lessonGroupFinished
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              dashPattern: const [9, 9],
                              radius: const Radius.circular(50.0),
                              child: ListTile(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween, // Align the lesson name and the play button
                                  children: [
                                    Text(
                                      lesson.name,
                                      style: isClickable
                                          ? null
                                          : TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground
                                                  .withOpacity(0.5),
                                            ),
                                    ),
                                    IconButton(
                                      onPressed: isClickable
                                          ? () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PrePostExerciseScreen(
                                                    lesson: lesson,
                                                    lessonGroup:
                                                        widget.lessonGroup,
                                                  ),
                                                ),
                                              ).then(
                                                (value) {
                                                  if (value == null) return;
                                                  if (lessons.last.id ==
                                                      lesson.id) {
                                                    setState(() {
                                                      lessonGroupFinished =
                                                          true;
                                                    });
                                                  }
                                                },
                                              );
                                            }
                                          : null,
                                      icon: Icon(
                                        Icons.play_arrow,
                                        color: isClickable
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.1),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50.0),
                          child: Column(
                            children: [
                              ElevatedButton(
                                onPressed: lessonGroupFinished
                                    ? () => Navigator.of(context).pop()
                                    : null,
                                child: const Text("Finish lesson group"),
                              ),
                              if (!lessonGroupFinished)
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 30.0),
                                  child: Text(
                                    "(Complete all lessons above to continue)",
                                    overflow: TextOverflow.clip,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ],
                          ),
                        )
                      ],
                    ),
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
