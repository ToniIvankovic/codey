import 'package:codey/models/entities/exercise.dart';
import 'package:codey/services/exercises_service.dart';
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
          exercises
              .removeWhere((element) => widget.exercises!.map((ex) => ex.id).contains(element.id));
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
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          for (var exercise in exercises)
            ListTile(
              title: Text("${exercise.id} (${exercise.type.toString()})"),
              onTap: () => Navigator.pop(context, exercise),
            ),
        ],
      ),
    );
  }
}
