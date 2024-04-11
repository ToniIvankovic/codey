import 'package:codey/models/entities/app_user.dart';
import 'package:codey/models/entities/class.dart';
import 'package:codey/services/user_interaction_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditClassScreen extends StatefulWidget {
  final Class classData;

  const EditClassScreen({super.key, required this.classData});

  @override
  State<EditClassScreen> createState() => _EditClassScreenState();
}

class _EditClassScreenState extends State<EditClassScreen> {
  late TextEditingController _nameController;
  late List<AppUser> _students;
  final List<AppUser> _selectedStudents = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.classData.name);
    _students = [];
    final userInteractionService = context.read<UserInteractionService>();
    userInteractionService.getAllUsers().then((users) {
      setState(() {
        _students.addAll(users);
        var existingStudents = _students.where((student) =>
            widget.classData.studentEmails.contains(student.email));
        _selectedStudents.addAll(existingStudents);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Class'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const Text('Students'),
              //TODO: consider making the same as in class creation (first the checked, then the unchecked)
              ListView.builder(
                shrinkWrap: true,
                itemCount: _students.length,
                itemBuilder: (context, index) {
                  final student = _students[index];
                  return CheckboxListTile(
                    title: Text(student.email),
                    value: _selectedStudents.contains(student),
                    onChanged: (value) {
                      setState(() {
                        if (value!) {
                          _selectedStudents.add(student);
                        } else {
                          _selectedStudents.remove(student);
                        }
                      });
                    },
                  );
                },
              ),
              ElevatedButton(
                onPressed: () {
                  final userInteractionService =
                      context.read<UserInteractionService>();
                  userInteractionService
                      .updateClass(
                    widget.classData.id,
                    _nameController.text,
                    _selectedStudents,
                  )
                      .then((updatedClass) {
                    Navigator.of(context).pop(updatedClass);
                  });
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
