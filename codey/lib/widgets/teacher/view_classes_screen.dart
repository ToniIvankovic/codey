import 'package:codey/models/entities/class.dart';
import 'package:codey/models/exceptions/no_changes_exception.dart';
import 'package:codey/services/user_interaction_service.dart';
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

  @override
  void initState() {
    super.initState();
    final userInteractionService = context.read<UserInteractionService>();
    userInteractionService.getAllClasses().then((classes) {
      setState(() {
        _classes.addAll(classes);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Classes'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Classes'),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _classes.length,
              itemBuilder: (context, index) {
                final localClass = _classes[index];
                return ListTile(
                  title: Text(localClass.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirmation'),
                            content: Text(
                                'Are you sure you want to delete the class ${localClass.name}?'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text('Delete'),
                                onPressed: () {
                                  final userInteractionService =
                                      context.read<UserInteractionService>();
                                  userInteractionService
                                      .deleteClass(localClass.id)
                                      .then((_) {
                                    setState(() {
                                      _classes.remove(localClass);
                                    });
                                    Navigator.of(context).pop();
                                  }).catchError((error) {
                                    if (error is NoChangesException) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('No changes were made'),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Failed to delete class'),
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
                    },
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ViewSingleClassScreen(
                          initialClassData: localClass,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
