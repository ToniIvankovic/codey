import 'package:codey/models/entities/exercise.dart';
import 'package:codey/models/entities/exercise_type.dart';
import 'package:codey/services/exercises_service.dart';
import 'package:codey/widgets/creator/exercise/create_exercise_screen.dart';
import 'package:codey/widgets/student/exercises/single_exercise_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PickExerciseScreen extends StatefulWidget {
  const PickExerciseScreen({super.key, this.exercises});
  final List<Exercise>? exercises;

  @override
  State<PickExerciseScreen> createState() => _PickExerciseScreenState();
}

class _PickExerciseScreenState extends State<PickExerciseScreen> {
  List<Exercise> exercisesAll = [];
  List<Exercise> exercisesFiltered = [];
  ExerciseType? selectedType;

  @override
  void initState() {
    super.initState();
    context.read<ExercisesService>().getAllExercises().then((value) {
      setState(() {
        exercisesAll = List.of(value);
        if (widget.exercises != null) {
          exercisesAll.removeWhere((element) =>
              widget.exercises!.map((ex) => ex.id).contains(element.id));
        }
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
        title: const Text('Pick exercise'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add new exercise'),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const CreateExerciseScreen();
                  })).then((value) {
                    if (value != null) {
                      setState(() {
                        exercisesAll.insert(0, value as Exercise);
                        filterExercises(null);
                      });
                    }
                  });
                },
              ),
            ),
            // filter by type
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text('Filter by type:'),
                ),
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
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: <Widget>[
                for (var exercise in exercisesFiltered)
                  ListTile(
                    leading: IconButton(
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
                    title: Text(exercisesService
                        .getExerciseDescriptionString(exercise)[0]),
                    subtitle: Text(exercisesService
                        .getExerciseDescriptionString(exercise)[1]),
                    onTap: () => Navigator.pop(context, exercise),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
