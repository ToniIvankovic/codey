import 'package:codey/models/entities/app_user.dart';
import 'package:codey/models/entities/class.dart';
import 'package:codey/models/exceptions/no_changes_exception.dart';
import 'package:codey/services/user_interaction_service.dart';
import 'package:codey/widgets/teacher/add_students_screen.dart';
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
  // ALL STUDENTS IN THE SCHOOL
  late final List<AppUser> _students = [];
  // STUDENTS ALREADY SELECTED FOR THE CLASS
  final List<AppUser> _selectedStudents = [];
  bool studentsLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.classData.name);
    fetchStudents();
  }

  void fetchStudents() {
    _students.clear();
    studentsLoading = true;
    final userInteractionService = context.read<UserInteractionService>();
    userInteractionService.getAllUsers().then((users) {
      setState(() {
        _students.addAll(users);
        var existingStudents = _students.where((student) =>
            widget.classData.studentEmails.contains(student.email));
        _selectedStudents.addAll(existingStudents);
        studentsLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uredi razred'),
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
                decoration: const InputDecoration(labelText: 'Ime razreda'),
              ),
              const Text('Učenici'),
              if (studentsLoading)
                const CircularProgressIndicator()
              else
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _selectedStudents.length,
                  itemBuilder: (context, index) {
                    final student = _selectedStudents[index];
                    return ListTile(
                        title: Text(
                            "${student.firstName} ${student.lastName} (${student.email})"),
                        trailing: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _selectedStudents.remove(student);
                            });
                          },
                        ));
                  },
                ),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (context) => AddStudentsScreen(
                        preselectedStudents: _selectedStudents,
                        classIdInProgress: widget.classData.id,
                      ),
                    ),
                  )
                      .then((value) {
                    if (value == null) return;
                    setState(() {
                      _selectedStudents.addAll((value as List<AppUser>).where(
                          (element) => !_selectedStudents.contains(element)));
                    });
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text("Dodaj učenike"),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Promjene spremljene'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                  }).catchError(
                    (error) {
                      if (error is NoChangesException) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nema promjena'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Navigator.of(context).pop(null);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Neuspjelo uređivanje razreda: $error'),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        Navigator.of(context).pop(null);
                      }
                    },
                  );
                },
                child: const Text('Spremi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
