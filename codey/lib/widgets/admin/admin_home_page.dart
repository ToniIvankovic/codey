import 'package:flutter/material.dart';

import 'create_creator_screen.dart';
import 'create_teacher_screen.dart';

class AdminHomePage extends StatelessWidget {
  final void Function() onLogoutSuper;

  const AdminHomePage({
    Key? key,
    required this.onLogoutSuper,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateCreatorScreen(),
                    ),
                  );
                },
                child: const Text("Create Creator"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateTeacherScreen(),
                    ),
                  );
                },
                child: const Text("Create Teacher"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
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
