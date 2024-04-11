import 'package:flutter/material.dart';

import 'exercise/edit_exercises_screen.dart';
import 'lesson_group/edit_lesson_groups_screen.dart';
import 'lesson/edit_lessons_screen.dart';

class CreatorHomePage extends StatelessWidget {
  const CreatorHomePage({
    super.key,
    required this.title,
    required this.onLogoutSuper,
  });

  final String title;
  final VoidCallback onLogoutSuper;

  @override
  Widget build(BuildContext context) {
    const padd = EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 8.0);
    var lessonGroupsButton = Expanded(
      child: Padding(
        padding: padd,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditLessonGroupsScreen(),
              ),
            );
          },
          child: const Text('Lesson groups'),
        ),
      ),
    );
    var lessonsButton = Expanded(
      child: Padding(
        padding: padd,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditLessonsScreen(),
              ),
            );
          },
          child: const Text('Lessons'),
        ),
      ),
    );
    var exercisesButton = Expanded(
      child: Padding(
        padding: padd,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditExercisesScreen(),
              ),
            );
          },
          child: const Text('Exercises'),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You are logged in as a creator.',
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                lessonGroupsButton,
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                lessonsButton,
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                exercisesButton,
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () async {
                  onLogoutSuper();
                },
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
