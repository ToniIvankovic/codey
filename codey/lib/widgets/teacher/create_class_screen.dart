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
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var userInteractionService = context.read<UserInteractionService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Class'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Class Name',
                    ),
                    onChanged: (value) {
                      setState(() {
                        className = value;
                      });
                    },
                    validator: (value) =>
                        value?.isEmpty ?? false ? "Enter a class name" : null,
                  ),
                ),
                if (students.isEmpty) const Text("No students selected"),
                if (students.isNotEmpty) ...[
                  const Text("Students:"),
                  for (var student in students)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => setState(() {
                              students.remove(student);
                            }),
                            icon: const Icon(Icons.clear),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: student.classId == null
                                ? Text(student.email)
                                : Text(
                                    "${student.email} (already in a class ${student.classId})"),
                          ),
                        ],
                      ),
                    ),
                ],
                //Add students
                TextButton.icon(
                    onPressed: () {
                      Navigator.of(context)
                          .push(
                        MaterialPageRoute(
                          builder: (context) =>
                              AddStudentsScreen(preselectedStudents: students),
                        ),
                      )
                          .then((value) {
                        if (value == null) return;
                        setState(() {
                          students.addAll((value as List<AppUser>)
                              .where((element) => !students.contains(element)));
                        });
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add Students")),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      formKey.currentState!.save();
                      userInteractionService
                          .createClass(className, students)
                          .then(
                            (createdClass) =>
                                Navigator.of(context).pop(createdClass.name),
                          )
                          .catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error.toString()),
                          ),
                        );
                      });
                    },
                    child: const Text("Create Class"),
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
