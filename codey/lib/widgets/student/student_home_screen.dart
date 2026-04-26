import 'package:codey/models/entities/app_user.dart';
import 'package:codey/models/entities/course.dart';
import 'package:codey/models/exceptions/unauthorized_exception.dart';
import 'package:codey/services/session_service.dart';
import 'package:codey/widgets/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'lesson_groups/lesson_groups_list_widget.dart';
import 'student_gamification_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  final AppUser user;
  final Course course;

  const StudentHomeScreen({
    super.key,
    required this.user,
    required this.course,
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
          iconTheme:
              IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: Text(widget.course.name),
              ),
              if (widget.user.gamificationEnabled) ...[
                Row(
                  children: [
                    Icon(
                      Icons.whatshot,
                      color: widget.user.didLessonToday
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context)
                              .colorScheme
                              .onInverseSurface
                              .withOpacity(0.5),
                    ),
                    Text(
                      widget.user.streak.toString(),
                      style: TextStyle(
                        color: widget.user.didLessonToday
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context)
                                .colorScheme
                                .onInverseSurface
                                .withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  //chest icon
                  icon: const Icon(Icons.military_tech),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentGamificationScreen(
                        user: widget.user,
                      ),
                    ),
                  ),
                ),
              ],
              // SETTINGS
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),

              // LOGOUT
              IconButton(
                icon: const Icon(Icons.logout),
                //alert dialog
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Odjava'),
                        content: const Text('Sigurno se želiš odjaviti?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Odustani'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.read<SessionService>().logout();
                            },
                            child: const Text('Odjavi se'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
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
      context.read<SessionService>().logout();
      return Text('Greška: $e');
    }
  }
}
