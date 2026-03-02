import 'package:codey/services/session_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'create_creator_screen.dart';
import 'create_teacher_screen.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({Key? key}) : super(key: key);

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
                  context.read<SessionService>().logout();
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
