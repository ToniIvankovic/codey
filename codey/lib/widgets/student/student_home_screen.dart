import 'package:codey/models/entities/app_user.dart';
import 'package:codey/models/exceptions/unauthorized_exception.dart';
import 'package:flutter/material.dart';

import 'lesson_groups/lesson_groups_list_widget.dart';
import 'student_profile_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  final VoidCallback onLogoutSuper;
  final AppUser user;

  const StudentHomeScreen({
    super.key,
    required this.onLogoutSuper,
    required this.user,
  });

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          titleTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary, fontSize: 18),
          actionsIconTheme:
              IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          title: const Text('Python Course'),
          actions: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  //fire emoji
                  Icon(
                    Icons.whatshot,
                    color: widget.user.didLessonToday
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                  ),
                  Text(
                    widget.user.streak.toString(),
                    style: TextStyle(
                      color: widget.user.didLessonToday
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: IconButton(
                icon: const Icon(Icons.person),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => StudentProfileScreen(
                              user: widget.user,
                            ))),
              ),
            ),
            //profile
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: widget.onLogoutSuper,
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: LessonGroupsListView(
                          key: ValueKey(widget.user),
                          user: widget.user,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } on UnauthenticatedException catch (e) {
      //TODO Does this ever run?
      widget.onLogoutSuper();
      return Text('Error: $e');
    }
  }
}
