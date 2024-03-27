import 'package:codey/models/entities/exercise.dart';
import 'package:codey/services/exercises_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'create_exercise_screen.dart';

class EditExercisesScreen extends StatefulWidget {
  const EditExercisesScreen({
    super.key,
  });

  @override
  State<EditExercisesScreen> createState() => _EditExercisesScreenState();
}

class _EditExercisesScreenState extends State<EditExercisesScreen> {
  List<Exercise> exercises = [];
  int? expandedId;

  @override
  void initState() {
    super.initState();
    // Load exercises
    final exercisesService = context.read<ExercisesService>();
    exercisesService.getAllExercises().then((value) {
      setState(() {
        exercises = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit exercises'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const CreateExerciseScreen();
                  })).then((value) {
                    if (value != null) {
                      setState(() {
                        exercises.add(value as Exercise);
                      });
                    }
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text("Add exercise"),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return ListTile(
                  title: Text('${exercise.id} ${exercise.type}'),
                  subtitle: expandedId == exercise.id
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(exercises[index].statement ?? ''),
                          ],
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      expandedId =
                          expandedId == exercise.id ? null : exercise.id;
                    });
                  },
                  leading: 
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // DELETE BUTTON
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          final exercisesService = context.read<ExercisesService>();
                          //confirm popup window
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Delete exercise'),
                                content: const Text(
                                    'Are you sure you want to delete this exercise?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      exercisesService
                                          .deleteExercise(exercise.id)
                                          .then((value) {
                                        setState(() {
                                          exercises.removeAt(index);
                                        });
                                      });
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      // EDIT BUTTON
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return CreateExerciseScreen(
                              existingExercise: exercise,
                            );
                          })).then((value) {
                            if (value != null) {
                              setState(() {
                                exercises[index] = value as Exercise;
                              });
                            }
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
