import 'package:codey/models/entities/app_user.dart';
import 'package:codey/models/entities/lesson.dart';
import 'package:codey/models/entities/lesson_group.dart';
import 'package:codey/services/lessons_service.dart';
import 'package:codey/services/user_service.dart';
import 'package:codey/widgets/student/lessons/pre_lesson_screen.dart';
import 'package:codey/widgets/student/lesson_groups/lesson_group_tips_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LessonsScreen extends StatefulWidget {
  final LessonGroup lessonGroup;
  final bool lessonGroupFinished;
  final AppUser user;

  const LessonsScreen({
    super.key,
    required this.lessonGroup,
    required this.lessonGroupFinished,
    required this.user,
  });

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  bool lessonGroupFinished = false;

  @override
  void initState() {
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        actionsIconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: ElevatedButton.icon(
              onPressed: widget.lessonGroup.tips?.isNotEmpty ?? false
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => LessonGroupTipsScreen(
                            lessonGroup: widget.lessonGroup,
                            lessonGroupFinished: lessonGroupFinished,
                          ),
                        ),
                      );
                    }
                  : null,
              label: const Text(
                "Nauči",
                style: TextStyle(fontSize: 16),
              ),
              icon: const Icon(Icons.lightbulb_outline),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: FutureBuilder<List<Lesson>>(
        future: lessonsFuture,
        builder: (BuildContext context, AsyncSnapshot<List<Lesson>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text("Učitavanje lekcija u cjelini..."),
                  ),
                  CircularProgressIndicator(
                    strokeWidth: 5,
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Pogreška: ${snapshot.error}');
          } else if (snapshot.data == null) {
            return const Text('Nema podataka');
          } else {
            var lessons = snapshot.data!;

            return StreamBuilder<AppUser?>(
              stream: user$,
              builder:
                  (BuildContext context, AsyncSnapshot<AppUser?> userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text("Učitavanje podataka o korisniku..."),
                        ),
                        CircularProgressIndicator(
                          strokeWidth: 5,
                        ),
                      ],
                    ),
                  );
                } else if (userSnapshot.hasError) {
                  return Text('Pogreška: ${userSnapshot.error}');
                } else if (userSnapshot.data == null) {
                  return const Text('Nema podataka o korisniku');
                } else {
                  AppUser user = userSnapshot.data!;
                  if (user.highestLessonGroupId == widget.lessonGroup.id &&
                      !lessonGroupFinished) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        lessonGroupFinished = true;
                      });
                    });
                  }
                  return SingleChildScrollView(
                    child: Center(
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height -
                              kToolbarHeight,
                          maxWidth: 600,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50.0, vertical: 15.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (lessonGroupFinished) ...[
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 30),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        size: 50,
                                      ),
                                      Text(
                                        "Cjelina dovršena",
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontSize: 20,
                                        ),
                                      ),
                                      if (lessonGroupFinished)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: ElevatedButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text("Dalje"),
                                                Icon(Icons.arrow_forward),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const Text("Riješi lekcije ponovno:")
                              ],
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
                                  return _generateSingleLessonItem(
                                    lesson: lesson,
                                    nextLessonId: user.nextLessonId,
                                    context: context,
                                    isClickable: isClickable,
                                    lastLessonId: lessons.last.id,
                                  );
                                },
                              ),
                              if (!lessonGroupFinished)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 50.0),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 30.0),
                                    child: Text(
                                      "(Dovrši sve lekcije iznad za nastavak)",
                                      overflow: TextOverflow.clip,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
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

  Widget _generateSingleLessonItem({
    required BuildContext context,
    required Lesson lesson,
    required int? nextLessonId,
    required bool isClickable,
    required int lastLessonId,
  }) {
    return
        // Border.all(
        //   color: lesson.id == nextLessonId && !lessonGroupFinished
        //       ? Theme.of(context).colorScheme.primary
        //       : Colors.transparent,
        Builder(builder: (context) {
      Border border;
      Color? color;
      bool solved = false;
      if (lesson.id == nextLessonId && !lessonGroupFinished) {
        border = Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 4.0,
        );
        color = Theme.of(context).colorScheme.inverseSurface;
      } else if (isClickable) {
        border = Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          width: 1.0,
        );
        color = Theme.of(context).colorScheme.inverseSurface;
        solved = true;
      } else {
        border = Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
          width: 1.0,
        );
        color = null;
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: border,
            color: color,
          ),
          child: ListTile(
            onTap: isClickable
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PreLessonScreen(
                          lesson: lesson,
                          lessonGroup: widget.lessonGroup,
                          user: widget.user,
                        ),
                      ),
                    ).then(
                      (value) {
                        if (value == null) return;
                        if (lastLessonId == lesson.id) {
                          setState(() {
                            lessonGroupFinished = true;
                          });
                        }
                      },
                    );
                  }
                : null,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  lesson.name,
                  textAlign: TextAlign.center,
                  style: isClickable
                      ? null
                      : TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                  overflow: TextOverflow.ellipsis,
                ),
                if(solved)
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 3, 0, 0),
                  child: Icon(
                    Icons.refresh,
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
