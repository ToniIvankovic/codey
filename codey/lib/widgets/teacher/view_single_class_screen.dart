import 'package:codey/models/entities/class.dart';
import 'package:codey/models/exceptions/no_changes_exception.dart';
import 'package:codey/widgets/teacher/edit_class_screen.dart';
import 'package:flutter/material.dart';

class ViewSingleClassScreen extends StatefulWidget {
  final Class initialClassData;
  const ViewSingleClassScreen({super.key, required this.initialClassData});

  @override
  State<ViewSingleClassScreen> createState() => _ViewSingleClassScreenState();
}

class _ViewSingleClassScreenState extends State<ViewSingleClassScreen> {
  late Class classData;

  @override
  void initState() {
    super.initState();
    classData = widget.initialClassData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Razred ${classData.name}'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID razreda: ${classData.id}'),
              Text('Naziv razreda: ${classData.name}'),
              const Text('Učenici:'),
              ListView.builder(
                shrinkWrap: true,
                itemCount: classData.studentEmails.length,
                itemBuilder: (context, index) {
                  final student = classData.studentEmails[index];
                  return ListTile(
                    title: Text(student),
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
                        });
                      },
                    ).catchError(
                      (error) {
                        if (error is NoChangesException) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Nema promjena'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Neuspjelo uređivanje razreda: $error'),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Uredi razred')),
            ],
          ),
        ),
      ),
    );
  }
}
