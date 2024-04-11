import 'package:codey/models/entities/app_user.dart';
import 'package:codey/models/exceptions/unauthorized_exception.dart';
import 'package:codey/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'lesson_groups/lesson_groups_list_widget.dart';

class StudentHomeScreen extends StatelessWidget {
  final VoidCallback onLogoutSuper;

  const StudentHomeScreen({
    super.key,
    required this.onLogoutSuper,
  });

  @override
  Widget build(BuildContext context) {
    Stream<AppUser?> user$ = context.read<UserService>().userStream;

    try {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40.0, 10.0, 40.0, 10.0),
            child: StreamBuilder(
              stream: user$,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                // Received data and user exists - form the list of lesson groups
                AppUser user = snapshot.data!;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(user.email),
                          Text(
                              "Last lesson: ${user.highestLessonId ?? 'Just begun'}"),
                          Text(
                              "Last lesson group: ${user.highestLessonGroupId ?? 'Just begun'}"),
                          Text("Next lesson: ${user.nextLessonId}"),
                          Text("Next lesson group: ${user.nextLessonGroupId}"),
                          Text("Roles: ${user.roles}"),
                          Text("XP: ${user.totalXp}"),
                        ],
                      ),
                    ),
                    LessonGroupsListView(user: user),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: onLogoutSuper,
                        child: const Text('Logout'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    } on UnauthenticatedException catch (e) {
      //TODO Does this ever run?
      onLogoutSuper();
      return Text('Error: $e');
    }
  }
}
