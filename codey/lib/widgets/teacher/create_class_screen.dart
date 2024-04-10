import 'package:codey/models/entities/app_user.dart';
import 'package:codey/services/user_interaction_service.dart';
import 'package:codey/widgets/teacher/add_students_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateClassScreen extends StatefulWidget {
  const CreateClassScreen({super.key});

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  String className = "";
  List<AppUser> students = [];

  @override
  Widget build(BuildContext context) {
    var userInteractionService = context.read<UserInteractionService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Class'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Class Name',
                ),
                onChanged: (value) {
                  setState(() {
                    className = value;
                  });
                },
              ),
            ),
            for (var student in students)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(student.email),
              ),
            //Add students
            TextButton.icon(
                onPressed: () {
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (context) => const AddStudentsScreen(),
                    ),
                  )
                      .then((value) {
                    if (value == null) return;
                    students.addAll(value as List<AppUser>);
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Students")),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  userInteractionService.createClass(className, students);
                  Navigator.of(context).pop();
                },
                child: const Text("Create Class"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
