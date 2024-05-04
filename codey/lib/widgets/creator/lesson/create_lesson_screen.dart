import 'package:codey/models/entities/exercise.dart';
import 'package:codey/services/exercises_service.dart';
import 'package:codey/services/lessons_service.dart';
import 'package:codey/widgets/creator/exercise/create_exercise_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../exercise/pick_exercise_screen.dart';

class CreateLessonScreen extends StatefulWidget {
  const CreateLessonScreen({super.key});

  @override
  State<CreateLessonScreen> createState() => _CreateLessonScreenState();
}

class _CreateLessonScreenState extends State<CreateLessonScreen> {
  String? name;
  String? specificTips;
  List<Exercise> exercises = [];

  @override
  Widget build(BuildContext context) {
    var exercisesService = context.read<ExercisesService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create new lesson'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(labelText: 'Name'),
              onChanged: (value) => setState(() => name = value),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Specific tips'),
              onChanged: (value) => setState(() => specificTips = value),
              maxLines: null,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Exercises:", style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
            ReorderableListView(
                shrinkWrap: true,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final Exercise item = exercises.removeAt(oldIndex);
                    exercises.insert(newIndex, item);
                  });
                },
                children: [
                  for (var exercise in exercises)
                    ListTile(
                      key: ValueKey(exercise),
                      title: Text(exercisesService
                          .getExerciseDescriptionString(exercise)[0]),
                      subtitle: Text(exercisesService
                          .getExerciseDescriptionString(exercise)[1]),
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () =>
                                setState(() => exercises.remove(exercise)),
                          ),
                          context
                              .read<ExercisesService>()
                              .generateExercisePreviewButton(context, exercise),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateExerciseScreen(
                                    key: ValueKey(exercise),
                                    existingExercise: exercise,
                                  ),
                                ),
                              ).then((value) {
                                if (value != null) {
                                  setState(() {
                                    exercises[exercises.indexOf(exercise)] =
                                        value as Exercise;
                                  });
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                ]),
            // ADD EXERCISES BUTTON
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton.icon(
                    onPressed: () async {
                      final exercise = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PickExerciseScreen(
                            key: ValueKey(exercises),
                            exercises: exercises,
                          ),
                        ),
                      );
                      if (exercise != null) {
                        setState(() => exercises.add(exercise as Exercise));
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add exercise'),
                  ),
                ),
              ],
            ),
            // CREATE LESSON BUTTON
            ElevatedButton(
              onPressed: () {
                context
                    .read<LessonsService>()
                    .createLesson(
                      name!,
                      specificTips,
                      exercises.map((e) => e.id).toList(),
                    )
                    .then((value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lesson created successfully'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                  Navigator.pop(context, value);
                });
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
