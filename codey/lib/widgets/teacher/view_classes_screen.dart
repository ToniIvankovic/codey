import 'package:codey/models/entities/class.dart';
import 'package:codey/models/exceptions/no_changes_exception.dart';
import 'package:codey/services/user_interaction_service.dart';
import 'package:codey/widgets/teacher/create_class_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'view_single_class_screen.dart';

class ViewClassesScreen extends StatefulWidget {
  const ViewClassesScreen({super.key});

  @override
  State<ViewClassesScreen> createState() => _ViewClassesScreenState();
}

class _ViewClassesScreenState extends State<ViewClassesScreen> {
  final List<Class> _classes = [];
  bool classesLoading = true;

  @override
  void initState() {
    super.initState();
    loadClasses();
  }

  void loadClasses() {
    classesLoading = true;
    _classes.clear();
    final userInteractionService = context.read<UserInteractionService>();
    userInteractionService.getAllClasses().then((classes) {
      setState(() {
        classesLoading = false;
        _classes.addAll(classes);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pregled razreda'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.1,
          vertical: MediaQuery.of(context).size.height * 0.05,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Razredi',
              style: TextStyle(
                fontSize: 24,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            if (classesLoading)
              const CircularProgressIndicator()
            else if (_classes.isEmpty)
              const Text('Nema razreda')
            else
              ListView.builder(
                shrinkWrap: true,
                itemCount: _classes.length,
                itemBuilder: (context, index) {
                  final localClass = _classes[index];
                  return ListTile(
                    title: Text(
                      localClass.name,
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          color: Theme.of(context).colorScheme.onBackground,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ViewSingleClassScreen(
                                  initialClassData: localClass,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Theme.of(context).colorScheme.onBackground,
                          onPressed: () =>
                              handleClassDelete(context, localClass),
                        ),
                      ],
                    ),
                  );
                },
              ),
            TextButton.icon(
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
                  loadClasses();
                });
              },
              icon: const Icon(Icons.add),
              label: const Text("Stvori novi razred"),
            )
          ],
        ),
      ),
    );
  }

  void handleClassDelete(BuildContext context, Class localClass) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Potvrda'),
          content:
              Text('Želite li sigurno izbrisati razred ${localClass.name}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Odustani'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Izbriši'),
              onPressed: () {
                final userInteractionService =
                    context.read<UserInteractionService>();
                userInteractionService.deleteClass(localClass.id).then((_) {
                  setState(() {
                    _classes.remove(localClass);
                  });
                  Navigator.of(context).pop();
                }).catchError((error) {
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
                        content: Text(
                            'Neuspjelo brisanje razreda (${error.toString()})'),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }
}
