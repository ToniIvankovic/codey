import 'package:codey/models/entities/course.dart';
import 'package:codey/models/entities/exercise.dart';
import 'package:codey/services/exercises_service.dart';
import 'package:codey/services/lessons_service.dart';
import 'package:codey/widgets/creator/exercise/create_exercise_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../exercise/pick_exercise_screen.dart';

class CreateLessonScreen extends StatefulWidget {
  final Course course;

  const CreateLessonScreen({super.key, required this.course});

  @override
  State<CreateLessonScreen> createState() => _CreateLessonScreenState();
}

class _CreateLessonScreenState extends State<CreateLessonScreen> {
  String? name;
  String? specificTips;
  List<Exercise> exercises = [];
  final TextEditingController _limitController = TextEditingController();
  final _specificTipsFocus = FocusNode();
  final _limitFocus = FocusNode();

  int get courseId => widget.course.id;

  @override
  void dispose() {
    _limitController.dispose();
    _specificTipsFocus.dispose();
    _limitFocus.dispose();
    super.dispose();
  }

  int? get _parsedLimit {
    final text = _limitController.text.trim();
    if (text.isEmpty) return null;
    return int.tryParse(text);
  }

  bool get _limitInvalid {
    final text = _limitController.text.trim();
    if (text.isEmpty) return false;
    final parsed = int.tryParse(text);
    return parsed == null || parsed == 0;
  }

  @override
  Widget build(BuildContext context) {
    var exercisesService = context.read<ExercisesService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create new lesson'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                decoration: const InputDecoration(labelText: 'Name'),
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _specificTipsFocus.requestFocus(),
                onChanged: (value) => setState(() => name = value),
              ),
              CallbackShortcuts(
                bindings: {
                  const SingleActivator(LogicalKeyboardKey.enter): () =>
                      _limitFocus.requestFocus(),
                },
                child: TextField(
                  focusNode: _specificTipsFocus,
                  decoration: const InputDecoration(labelText: 'Specific tips'),
                  onChanged: (value) => setState(() => specificTips = value),
                  maxLines: null,
                ),
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
                                      courseId: courseId,
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
              // LIMIT FIELD
              TextField(
                controller: _limitController,
                focusNode: _limitFocus,
                decoration: InputDecoration(
                  labelText: widget.course.defaultExerciseLimit != null
                      ? 'Exercise limit (optional - default: ${widget.course.defaultExerciseLimit})'
                      : 'Exercise limit (optional)',
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => FocusScope.of(context).unfocus(),
                onChanged: (_) => setState(() {}),
              ),
              Builder(builder: (context) {
                if (_limitInvalid) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      'Invalid limit. Use -1 (all exercises), a positive number, or leave empty for course default.',
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  );
                }
                final effectiveLimit = _parsedLimit ?? widget.course.defaultExerciseLimit;
                if (effectiveLimit != null && effectiveLimit > 0 && exercises.length > effectiveLimit) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      'Pool: ${exercises.length} exercises, showing $effectiveLimit — ${exercises.length - effectiveLimit} excluded each session',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              // CREATE LESSON BUTTON
              ElevatedButton(
                onPressed: _limitInvalid ? null : () {
                  context
                      .read<LessonsService>()
                      .createLesson(
                        name!,
                        specificTips,
                        exercises.map((e) => e.id).toList(),
                        exerciseLimit: _parsedLimit,
                      )
                      .then((value) {
                    if (!mounted) return;
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
      ),
    );
  }
}
