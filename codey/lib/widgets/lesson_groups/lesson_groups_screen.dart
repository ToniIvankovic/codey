import 'package:codey/models/entities/app_user.dart';
import 'package:codey/models/exceptions/unauthorized_exception.dart';
import 'package:codey/models/entities/lesson_group.dart';
import 'package:codey/services/lesson_groups_service.dart';
import 'package:codey/services/session_service.dart';
import 'package:codey/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'lesson_groups_list_widget.dart';

class LessonGroupsScreen extends StatelessWidget {
  final VoidCallback onLogoutSuper;

  const LessonGroupsScreen({
    super.key,
    required this.onLogoutSuper,
  });

  @override
  Widget build(BuildContext context) {
    LessonGroupsService lessonGroupsService =
        context.read<LessonGroupsService>();
    final sessionService = context.read<SessionService>();
    Stream<AppUser?> user$ = context.read<UserService>().userStream;
    List<ListItem> lessonGroupsListItems = [];
    void onLogout() {
      sessionService.logout();
      onLogoutSuper();
    }

    try {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(40.0, 10.0, 40.0, 10.0),
          child: FutureBuilder<List<LessonGroup>>(
            future: lessonGroupsService.getAllLessonGroups(),
            // Call the getUser method from AuthService to get the user
            builder:
                (BuildContext context, AsyncSnapshot<List<LessonGroup>> snapshot) {
              // Error handling
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(
                  strokeWidth: 5,
                );
              } else if (snapshot.hasError) {
                if (snapshot.error is UnauthenticatedException) {
                  onLogout();
                }
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.data == null) {
                return const Text('No data');
              }
              
              // Lesson groups exist, find user
              List<LessonGroup> lessonGroups = snapshot.data!;
              return StreamBuilder(
                  stream: user$,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
              
                    // Received data and user exists - form the list of lesson groups
                    AppUser user = snapshot.data!;
                    lessonGroupsListItems = lessonGroups
                        .map<ListItem>(
                          (item) => ListItem(
                            lessonGroup: item,
                            clickable: item.id <= (user.nextLessonGroupId ?? 0),
                            isExpanded: false,
                          ),
                        )
                        .toList();
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
                              Text("Roles: ${user.roles}")
                            ],
                          ),
                        ),
                        LessonGroupsListView(data: lessonGroupsListItems),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                            onPressed: onLogout,
                            child: const Text('Logout'),
                          ),
                        ),
                      ],
                    );
                  });
            },
          ),
        ),
      );
    } on UnauthenticatedException catch (e) {
      //TODO Does this ever run?
      onLogout();
      return Text('Error: $e');
    }
  }
}
