import 'package:codey/models/entities/exercise.dart';
import 'package:codey/models/entities/exercise_LA.dart';
import 'package:codey/models/entities/exercise_MC.dart';
import 'package:codey/models/entities/exercise_SA.dart';
import 'package:codey/models/entities/exercise_SCW.dart';
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
  List<Exercise> exercises = [];
  @override
  void initState() {
    super.initState();
    context.read<ExercisesService>().getAllExercises().then((value) {
      setState(() {
        exercises = List.of(value);
        if (widget.exercises != null) {
          exercises.removeWhere((element) =>
              widget.exercises!.map((ex) => ex.id).contains(element.id));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
                        exercises.add(value as Exercise);
                      });
                    }
                  });
                },
              ),
            ),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: <Widget>[
                for (var exercise in exercises)
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
                    title: Text(
                        "${exercise.type.toString()} (${exercise.id}) - ${_formExerciseTitle(exercise)}"),
                    onTap: () => Navigator.pop(context, exercise),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formExerciseTitle(Exercise exercise) {
    if (exercise is ExerciseMC) {
      return '${exercise.statement ?? ''} ${exercise.statementCode ?? ''} ${exercise.statementOutput ?? ''} ${exercise.question ?? ''} (${exercise.answerOptions.values.join(', ')})';
    } else if (exercise is ExerciseSA) {
      return '${exercise.statement ?? ''} ${exercise.statementCode ?? ''} ${exercise.statementOutput ?? ''} ${exercise.question ?? ''}';
    } else if (exercise is ExerciseLA) {
      return '${exercise.statement ?? ''} ${exercise.statementOutput ?? ''} (${exercise.answerOptions?.values.join(",") ?? ''})';
    } else if (exercise is ExerciseSCW) {
      return '${exercise.statement ?? ''} ${exercise.statementCode} ${exercise.statementOutput ?? ''}';
    } else {
      throw Exception('Unknown exercise type');
    }
  }
}
