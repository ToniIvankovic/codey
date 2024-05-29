import 'package:codey/models/entities/app_user.dart';
import 'package:codey/services/user_interaction_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddStudentsScreen extends StatefulWidget {
  const AddStudentsScreen({
    super.key,
    required this.preselectedStudents,
    this.classIdInProgress,
  });
  final List<AppUser> preselectedStudents;
  final int? classIdInProgress;

  @override
  State<AddStudentsScreen> createState() => _AddStudentsScreenState();
}

class _AddStudentsScreenState extends State<AddStudentsScreen> {
  List<AppUser> allQueriedStudents = <AppUser>[];
  List<AppUser> selectedStudents = <AppUser>[];
  String query = "";
  bool loadingStudents = true;

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  void fetchStudents() {
    setState(() {
      loadingStudents = true;
    });
    var userInteractionService = context.read<UserInteractionService>();
    userInteractionService.getAllUsers().then((value) {
      setState(() {
        allQueriedStudents = value;
        allQueriedStudents.removeWhere((element) => widget.preselectedStudents
            .map((preselectedStudent) => preselectedStudent.email)
            .contains(element.email));
        loadingStudents = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var userInteractionService = context.read<UserInteractionService>();

    var nonSelectedStudents = List.from(allQueriedStudents);
    nonSelectedStudents.removeWhere(
      (element) => selectedStudents
          .map((selectedStudent) => selectedStudent.email)
          .contains(element.email),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj učenike'),
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
                  labelText: 'Traži učenike',
                ),
                onChanged: (value) {
                  setState(() {
                    query = value;
                    loadingStudents = true;
                  });
                  userInteractionService.queryUsers(query).then((value) {
                    setState(() {
                      allQueriedStudents = value;
                      allQueriedStudents.removeWhere(
                        (element) => widget.preselectedStudents
                            .map((e) => e.email)
                            .contains(element.email),
                      );
                      loadingStudents = false;
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
                    child: student.classId != null &&
                            student.classId != widget.classIdInProgress
                        ? Text(
                            "${student.email} (već u razredu ${student.classId})")
                        : Text(student.email),
                  ),
                ],
              ),
            if (loadingStudents)
              const CircularProgressIndicator()
            else
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
                      child: student.classId != null &&
                              student.classId != widget.classIdInProgress
                          ? Text(
                              "${student.email} (već u razredu ${student.classId})")
                          : Text(student.email),
                    ),
                  ],
                ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, selectedStudents);
              },
              child: const Text('Dodaj označene učenike'),
            ),
          ],
        ),
      ),
    );
  }
}
