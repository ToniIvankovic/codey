import 'package:codey/models/entities/app_user.dart';
import 'package:codey/services/user_interaction_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddStudentsScreen extends StatefulWidget {
  const AddStudentsScreen({
    super.key,
    required this.preselectedStudents,
  });
  final List<AppUser> preselectedStudents;

  @override
  State<AddStudentsScreen> createState() => _AddStudentsScreenState();
}

class _AddStudentsScreenState extends State<AddStudentsScreen> {
  List<AppUser> allQueriedStudents = <AppUser>[];
  List<AppUser> selectedStudents = <AppUser>[];
  String query = "";

  @override
  void initState() {
    super.initState();
    var userInteractionService = context.read<UserInteractionService>();
    userInteractionService.getAllUsers().then((value) {
      setState(() {
        allQueriedStudents = value;
        allQueriedStudents.removeWhere((element) => widget.preselectedStudents
            .map((preselectedStudent) => preselectedStudent.email)
            .contains(element.email));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var userInteractionService = context.read<UserInteractionService>();

    var nonSelectedStudents = List.of(allQueriedStudents);
    nonSelectedStudents.removeWhere(
      (element) => selectedStudents
          .map((selectedStudent) => selectedStudent.email)
          .contains(element.email),
    );
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
                      allQueriedStudents = value;
                      allQueriedStudents.removeWhere((element) =>
                          widget.preselectedStudents.contains(element));
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
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, selectedStudents);
              },
              child: const Text('Add selected students'),
            ),
          ],
        ),
      ),
    );
  }
}
