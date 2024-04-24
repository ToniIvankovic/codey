import 'package:codey/models/entities/exercise.dart';
import 'package:codey/services/lessons_service.dart';
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
            for (var exercise in exercises)
              ListTile(
                title: Text("${exercise.id} (${exercise.type})"),
                leading: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => exercises.remove(exercise)),
                ),
              ),

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
                Navigator.pop(
                  context,
                  context.read<LessonsService>().createLesson(
                        name!,
                        specificTips,
                        exercises.map((e) => e.id).toList(),
                      ),
                );
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
