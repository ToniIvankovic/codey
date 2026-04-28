import 'dart:async';

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
  late Future<List<Lesson>> _lessonsFuture;
  AppUser? _user;
  StreamSubscription? _userSub;

  @override
  void initState() {
    super.initState();
    lessonGroupFinished = widget.lessonGroupFinished;
    _lessonsFuture =
        context.read<LessonsService>().getLessonsForGroup(widget.lessonGroup);
    _userSub = context.read<UserService>().userStream.listen((user) {
      if (!mounted) return;
      setState(() {
        _user = user;
        if (user.highestLessonGroupId == widget.lessonGroup.id) {
          lessonGroupFinished = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        future: _lessonsFuture,
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
                  CircularProgressIndicator(strokeWidth: 5),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Pogreška: ${snapshot.error}');
          } else if (snapshot.data == null || _user == null) {
            return const Center(
                child: CircularProgressIndicator(strokeWidth: 5));
          }

          final lessons = snapshot.data!;
          final user = _user!;

          return SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height - kToolbarHeight,
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
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: Theme.of(context).colorScheme.primary,
                                size: 50,
                              ),
                              Text(
                                "Cjelina dovršena",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 20,
                                ),
                              ),
                              if (lessonGroupFinished)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
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
                          if (!lessonGroupFinished) {
                            isClickable =
                                widget.lessonGroup.lessons.indexOf(lesson.id) <=
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
    return Builder(builder: (context) {
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
                Flexible(
                  child: Text(
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
                    softWrap: true,
                  ),
                ),
                if (solved)
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
