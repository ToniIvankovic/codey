import 'package:codey/models/entities/app_user.dart';
import 'package:codey/services/user_interaction_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddStudentsScreen extends StatefulWidget {
  const AddStudentsScreen({super.key});

  @override
  State<AddStudentsScreen> createState() => _AddStudentsScreenState();
}

class _AddStudentsScreenState extends State<AddStudentsScreen> {
  List<AppUser> students = <AppUser>[];
  List<AppUser> selectedStudents = <AppUser>[];
  String query = "";

  @override
  Widget build(BuildContext context) {
    var userInteractionService = context.read<UserInteractionService>();

    var nonSelectedStudents = List.of(students);
    nonSelectedStudents
        .removeWhere((element) => selectedStudents.contains(element));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Students'),
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
                  labelText: 'Search for students',
                ),
                onChanged: (value) {
                  setState(() {
                    query = value;
                  });
                  userInteractionService.queryUsers(query).then((value) {
                    setState(() {
                      students = value;
                    });
                  });
                },
              ),
            ),
            for (var student in selectedStudents)
              Row(
                children: [
                  Checkbox(
                    value: selectedStudents.contains(student),
                    onChanged: (value) {
                      if (value!) {
                        setState(() {
                          selectedStudents.add(student);
                        });
                      } else {
                        setState(() {
                          selectedStudents.remove(student);
                        });
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(student.email),
                  ),
                ],
              ),
            for (var student in nonSelectedStudents)
              Row(
                children: [
                  Checkbox(
                    value: selectedStudents.contains(student),
                    onChanged: (value) {
                      if (value!) {
                        setState(() {
                          selectedStudents.add(student);
                        });
                      } else {
                        setState(() {
                          selectedStudents.remove(student);
                        });
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(student.email),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
