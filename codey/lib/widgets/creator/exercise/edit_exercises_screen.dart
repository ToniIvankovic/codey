import 'package:codey/models/entities/exercise.dart';
import 'package:codey/models/entities/exercise_type.dart';
import 'package:codey/services/exercises_service.dart';
import 'package:codey/widgets/student/exercises/single_exercise_widget.dart';
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
  List<Exercise> exercisesAll = [];
  List<Exercise> exercisesFiltered = [];
  ExerciseType? selectedType;

  int? expandedId;
  bool loadingStatistics = false;
  late bool loadingExercises;

  @override
  void initState() {
    super.initState();
    // Load exercises
    final exercisesService = context.read<ExercisesService>();
    loadingExercises = true;
    exercisesService.getAllExercises().then((value) {
      setState(() {
        loadingExercises = false;
        exercisesAll = value.toList();
        exercisesAll.sort((a, b) => -a.id.compareTo(b.id));
        exercisesFiltered = List.of(exercisesAll);
      });
    });
  }

  void filterExercises(ExerciseType? type) {
    setState(() {
      if (type == null) {
        exercisesFiltered = List.of(exercisesAll);
      } else {
        exercisesFiltered =
            exercisesAll.where((element) => element.type == type).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var exercisesService = context.read<ExercisesService>();
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const CreateExerciseScreen();
                  })).then((value) {
                    if (value != null) {
                      setState(() {
                        exercisesAll.add(value as Exercise);
                      });
                    }
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text("Add exercise"),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: loadingStatistics
                        ? null
                        : () {
                            setState(() {
                              loadingStatistics = true;
                            });
                            context
                                .read<ExercisesService>()
                                .calculateStatistics(exercisesAll)
                                .then(
                              (value) {
                                for (var exercise in exercisesAll) {
                                  exercise.statistics = value
                                      .where((element) =>
                                          element.exerciseId == exercise.id)
                                      .first;
                                }
                                setState(() {
                                  loadingStatistics = false;
                                });
                              },
                            );
                          },
                    icon: const Icon(Icons.calculate),
                    label: const Text("Calculate statistics"),
                  ),
                  if (loadingStatistics)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.0),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
            if (loadingExercises)
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.0),
                    child: CircularProgressIndicator(),
                  ),
                ],
              )
            else ...[
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text('Filter by type:'),
                  ),
                  Expanded(
                    child: Wrap(
                      direction: Axis.horizontal,
                      children: [
                        for (var type in ExerciseType.values)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  if (selectedType == type) {
                                    selectedType = null;
                                  } else {
                                    selectedType = type;
                                  }
                                });
                                filterExercises(selectedType);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedType == type
                                    ? Theme.of(context).colorScheme.secondary
                                    : null,
                              ),
                              child: Text(type.toString()),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: exercisesFiltered.length,
                itemBuilder: (context, index) {
                  final exercise = exercisesFiltered[index];
                  return ListTile(
                    title: Row(
                      children: [
                        Text(exercisesService
                            .getExerciseDescriptionString(exercise)[0]),
                        if (exercise.statistics != null) ...[
                          Text(
                            ' -- current difficulty: ${exercise.difficulty} -> suggested: ${exercise.statistics!.suggestedDifficulty}',
                            style: TextStyle(
                                color: (exercise.difficulty -
                                                exercise.statistics!
                                                    .suggestedDifficulty)
                                            .abs() <
                                        1
                                    ? null
                                    : Colors.red),
                          )
                        ]
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exercisesService
                            .getExerciseDescriptionString(exercise)[1]),
                        if (exercise.statistics != null) ...[
                          Text(
                            'avg. score correct: ${exercise.statistics!.averageDifficultyCorrect}',
                            style:
                                exercise.statistics!.averageDifficultyCorrect ==
                                        null
                                    ? const TextStyle(color: Colors.grey)
                                    : null,
                          ),
                          Text(
                            'avg. score incorrect: ${exercise.statistics!.averageDifficultyIncorrect}',
                            style: exercise.statistics!
                                        .averageDifficultyIncorrect ==
                                    null
                                ? const TextStyle(color: Colors.grey)
                                : null,
                          ),
                        ]
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        expandedId =
                            expandedId == exercise.id ? null : exercise.id;
                      });
                    },
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // DELETE BUTTON
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            final exercisesService =
                                context.read<ExercisesService>();
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
                                            exercisesAll.removeAt(exercisesAll
                                                .indexWhere((element) =>
                                                    element.id == exercise.id));
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
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return CreateExerciseScreen(
                                existingExercise: exercise,
                              );
                            })).then((value) {
                              if (value != null) {
                                setState(() {
                                  exercisesAll[exercisesAll.indexWhere(
                                          (element) =>
                                              element.id == value.id)] =
                                      value as Exercise;
                                });
                                filterExercises(selectedType);
                              }
                            });
                          },
                        ),
                        // VIEW EXERCISE BUTTON
                        IconButton(
                          icon: const Icon(Icons.remove_red_eye),
                          onPressed: () {
                            final exercisesService =
                                context.read<ExercisesService>();
                            exercisesService.startMockExerciseSession(exercise);
                            exercisesService.getNextExercise();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  appBar: AppBar(
                                    title: const Text('Preview exercise'),
                                  ),
                                  body: SingleExerciseWidget(
                                    exercisesService: exercisesService,
                                    onSessionFinished: () {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        Navigator.pop(context);
                                      });
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ]
          ],
        ),
      ),
    );
  }
}
