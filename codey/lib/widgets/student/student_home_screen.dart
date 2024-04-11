import 'package:codey/models/entities/app_user.dart';
import 'package:codey/models/exceptions/unauthorized_exception.dart';
import 'package:codey/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'lesson_groups/lesson_groups_list_widget.dart';
import 'student_profile_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  final VoidCallback onLogoutSuper;

  const StudentHomeScreen({
    super.key,
    required this.onLogoutSuper,
  });

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  AppUser? userForProfile;

  @override
  Widget build(BuildContext context) {
    Stream<AppUser?> user$ = context.read<UserService>().userStream;

    try {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        appBar: AppBar(
          title: const Text('Student Home'),
          actions: [
            if (userForProfile != null)
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => StudentProfileScreen(
                              user: userForProfile!,
                            ))),
              ),
            //profile
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: widget.onLogoutSuper,
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40.0, 10.0, 40.0, 10.0),
            child: StreamBuilder(
              stream: user$,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                AppUser user = snapshot.data!;
                //cannot call setState in build method
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  setState(() {
                    userForProfile = snapshot.data!;
                  });
                });

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(user.email),
                        ],
                      ),
                    ),
                    LessonGroupsListView(user: user),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: widget.onLogoutSuper,
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
      widget.onLogoutSuper();
      return Text('Error: $e');
    }
  }
}
