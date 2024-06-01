import 'package:codey/models/entities/app_user.dart';
import 'package:codey/models/entities/class.dart';
import 'package:codey/services/user_interaction_service.dart';
import 'package:codey/widgets/student/gamification_widgets/leaderboard_widget.dart';
import 'package:codey/widgets/teacher/edit_class_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'view_single_student_screen.dart';

class ViewSingleClassScreen extends StatefulWidget {
  final Class initialClassData;
  const ViewSingleClassScreen({super.key, required this.initialClassData});

  @override
  State<ViewSingleClassScreen> createState() => _ViewSingleClassScreenState();
}

class _ViewSingleClassScreenState extends State<ViewSingleClassScreen> {
  late Class classData;
  // ALL STUDENTS IN THE SCHOOL
  late final List<AppUser> _students = [];
  // STUDENTS ALREADY SELECTED FOR THE CLASS
  final List<AppUser> _selectedStudents = [];
  bool studentsLoading = true;

  @override
  void initState() {
    super.initState();
    classData = widget.initialClassData;
    fetchStudents();
  }

  void fetchStudents() {
    _students.clear();
    _selectedStudents.clear();
    studentsLoading = true;
    final userInteractionService = context.read<UserInteractionService>();
    userInteractionService.getAllUsers().then((users) {
      setState(() {
        _students.addAll(users);
        var existingStudents = _students.where(
            (student) => classData.studentEmails.contains(student.email));
        _selectedStudents.addAll(existingStudents);
        studentsLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Razred ${classData.name}'),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop(classData);
          return false;
        },
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 50.0, vertical: 50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Naziv razreda: ${classData.name}',
                        style: const TextStyle(fontSize: 18),
                        overflow: TextOverflow.fade,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'ID: ${classData.id}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Učenici:',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                if (studentsLoading)
                  const CircularProgressIndicator()
                else
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _selectedStudents.length,
                    itemBuilder: (context, index) {
                      final student = _selectedStudents[index];
                      return ListTile(
                        leading: IconButton(
                          icon: const Icon(Icons.remove_red_eye),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ViewSingleStudentScreen(
                                  student: student,
                                ),
                              ),
                            );
                          },
                        ),
                        title: Row(
                          children: [
                            Text("${student.firstName} ${student.lastName}",
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 20),
                            Text("(${student.email})",
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      );
                    },
                  ),
                //EDIT CLASS
                TextButton.icon(
                    onPressed: () {
                      Navigator.of(context)
                          .push(
                        MaterialPageRoute(
                          builder: (context) => EditClassScreen(
                            classData: classData,
                          ),
                        ),
                      )
                          .then(
                        (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            classData = value as Class;
                            fetchStudents();
                          });
                        },
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Uredi razred')),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: LeaderboardWidget(
                          key: ValueKey(classData),
                          requestedByTeacher: true,
                          classId: classData.id,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
