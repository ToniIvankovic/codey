import 'package:flutter/material.dart';

import 'create_class_screen.dart';
import 'view_classes_screen.dart';

class TeacherHomePage extends StatelessWidget {
  final void Function() onLogoutSuper;

  const TeacherHomePage({
    Key? key,
    required this.onLogoutSuper,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Home Page'),
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
                      builder: (context) => const ManageClassesScreen(),
                    ),
                  );
                },
                child: const Text("Upravljaj razredima"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  onLogoutSuper();
                },
                child: const Text('Odjava'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ManageClassesScreen extends StatelessWidget {
  const ManageClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upravljaj razredima'),
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
                      builder: (context) => const ViewClassesScreen(),
                    ),
                  );
                },
                child: const Text("Pregled razreda"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (context) => const CreateClassScreen(),
                    ),
                  )
                      .then((className) {
                    if (className == null) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Stvoren razred $className"),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  });
                },
                child: const Text("Stvori razred"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
