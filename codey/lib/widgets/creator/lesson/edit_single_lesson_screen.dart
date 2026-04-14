import 'package:codey/models/entities/course.dart';
import 'package:codey/models/entities/exercise.dart';
import 'package:codey/models/entities/lesson.dart';
import 'package:codey/models/entities/lesson_group.dart';
import 'package:codey/models/exceptions/no_changes_exception.dart';
import 'package:codey/services/exercises_service.dart';
import 'package:codey/services/lessons_service.dart';
import 'package:codey/services/user_service.dart';
import 'package:codey/widgets/creator/exercise/create_exercise_screen.dart';
import 'package:codey/widgets/creator/exercise/pick_exercise_screen.dart';
import 'package:codey/widgets/student/lessons/pre_lesson_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditSingleLessonScreen extends StatefulWidget {
  final Lesson lesson;
  final Course? course;

  const EditSingleLessonScreen(this.lesson, {super.key, this.course});

  @override
  State<EditSingleLessonScreen> createState() => _EditSingleLessonScreenState();
}

class _EditSingleLessonScreenState extends State<EditSingleLessonScreen> {
  String? nameInitial;
  String? specificTipsInitial;
  int? exerciseLimitInitial;
  List<Exercise> exercisesInitial = [];
  String? nameEdited;
  String? specificTipsEdited;
  List<Exercise> exercisesEdited = [];
  late String nameLocal;
  late String? specificTipsLocal;
  List<Exercise> exercisesLocal = [];
  bool nameEditable = false;
  bool specificTipsEditable = false;
  bool exercisesEditable = false;
  int? expandedExerciseId;
  late TextEditingController _limitController;

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
  void initState() {
    super.initState();
    final exerciseService = context.read<ExercisesService>();
    nameInitial = widget.lesson.name;
    nameLocal = widget.lesson.name;
    specificTipsInitial = widget.lesson.specificTips;
    specificTipsLocal = widget.lesson.specificTips;
    exerciseLimitInitial = widget.lesson.exerciseLimit;
    _limitController = TextEditingController(
      text: widget.lesson.exerciseLimit?.toString() ?? '',
    );
    exerciseService.getAllExercisesForLesson(widget.lesson).then(
          (value) => setState(() {
            exercisesInitial = List.of(value);
            exercisesLocal = List.of(value);
          }),
        );
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nameRow = _generateNameRow();
    final specificTipsRow = _generateSpecificTipsRow();
    final exercisesRow = _generateExercisesRow();
    final bool madeChanges = nameLocal != nameInitial ||
        specificTipsLocal != specificTipsInitial ||
        _parsedLimit != exerciseLimitInitial ||
        !listEquals(exercisesLocal, exercisesInitial);
    final editInProgress =
        nameEditable || specificTipsEditable || exercisesEditable;
    final bool canSave = madeChanges && !editInProgress && !_limitInvalid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit lesson'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              nameRow,
              specificTipsRow,
              exercisesRow,
              _buildLimitRow(),
              ElevatedButton(
                onPressed: canSave
                    ? () {
                        context
                            .read<LessonsService>()
                            .updateLesson(
                              widget.lesson.id,
                              nameLocal,
                              specificTipsLocal,
                              exercisesLocal.map((e) => e.id).toList(),
                              exerciseLimit: _parsedLimit,
                            )
                            .then((value) {
                          if (!mounted) return;
                          Navigator.pop(context, value);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Lesson updated successfully"),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }).catchError((error) {
                          if (!mounted) return;
                          if (error is NoChangesException) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("No changes made"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text("Failed to update lesson - $error"),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                          Navigator.pop(context, null);
                        });
                      }
                    : null,
                child: const Text('Save'),
              ),
              if (editInProgress)
                const Text("Please save or cancel changes first")
              else if (!madeChanges)
                const Text("No changes made"),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLimitRow() {
    final poolSize = exercisesLocal.length;
    final courseDefault = widget.course?.defaultExerciseLimit;
    final effectiveLimit = _parsedLimit ?? courseDefault;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _limitController,
            decoration: InputDecoration(
              labelText: courseDefault != null
                  ? 'Exercise limit (optional - default: $courseDefault)'
                  : 'Exercise limit (optional)',
            ),
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
          if (_limitInvalid)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Invalid limit. Use -1 (all exercises), a positive number, or leave empty for course default.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            )
          else if (effectiveLimit != null && effectiveLimit > 0 && poolSize > effectiveLimit)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Pool: $poolSize exercises, showing $effectiveLimit — ${poolSize - effectiveLimit} excluded each session',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }

  Row _generateNameRow() {
    return Row(
      children: [
        nameEditable
            ? IconButton(
                onPressed: () {
                  setState(() {
                    nameLocal = nameEdited ?? nameLocal;
                    nameEdited = null;
                    nameEditable = false;
                  });
                },
                icon: const Icon(Icons.save),
              )
            : IconButton(
                onPressed: () {
                  setState(() {
                    nameEditable = !nameEditable;
                  });
                },
                icon: const Icon(Icons.edit),
              ),
        const Text("Name: "),
        if (nameEditable) ...[
          Expanded(
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: "Name",
              ),
              initialValue: nameLocal,
              maxLength: 100,
              onChanged: (String value) {
                nameEdited = value;
              },
            ),
          ),
        ] else
          Expanded(
            child: Text(nameLocal),
          ),
      ],
    );
  }

  Row _generateSpecificTipsRow() {
    return Row(
      children: [
        specificTipsEditable
            ? IconButton(
                onPressed: () {
                  setState(() {
                    specificTipsLocal = specificTipsEdited;
                    specificTipsEdited = null;
                    specificTipsEditable = false;
                  });
                },
                icon: const Icon(Icons.save),
              )
            : Column(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        specificTipsEditable = !specificTipsEditable;
                        specificTipsEdited = specificTipsLocal;
                      });
                    },
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () {
                      context.read<UserService>().userStream.first.then(
                        (value) {
                          return Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PreLessonScreen(
                                  lessonGroup: LessonGroup(
                                    id: 0,
                                    name: "Lesson group",
                                    tips: "Lesson group description",
                                    lessons: [widget.lesson.id],
                                    order: 0,
                                    courseId: widget.lesson.courseId,
                                  ),
                                  lesson: Lesson(
                                    id: 0,
                                    name: "Lesson",
                                    specificTips: specificTipsLocal,
                                    exerciseIds: exercisesLocal
                                        .map((e) => e.id)
                                        .toList(),
                                    courseId: widget.lesson.courseId,
                                  ),
                                  user: value),
                            ),
                          ).then((value) {
                            if (value != null) {
                              setState(() {
                                exercisesLocal.add(value as Exercise);
                              });
                            }
                          });
                        },
                      );
                    },
                    icon: const Icon(Icons.remove_red_eye),
                  ),
                ],
              ),
        const Text("Specific tips: "),
        if (specificTipsEditable) ...[
          Expanded(
            child: TextFormField(
              minLines: 1,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Specific tips",
              ),
              initialValue: specificTipsLocal,
              onChanged: (String value) {
                specificTipsEdited = value;
              },
            ),
          ),
        ] else
          Expanded(
              child: Text(
            specificTipsLocal ?? "",
          )),
      ],
    );
  }

  Row _generateExercisesRow() {
    var exercisesService = context.read<ExercisesService>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // EDIT/SAVE BUTTON
        exercisesEditable
            ? IconButton(
                onPressed: () {
                  setState(() {
                    exercisesLocal = List.of(exercisesEdited);
                    exercisesEdited = [];
                    exercisesEditable = false;
                    expandedExerciseId = null;
                  });
                },
                icon: const Icon(Icons.save),
              )
            : IconButton(
                onPressed: () {
                  setState(() {
                    exercisesEditable = !exercisesEditable;
                    exercisesEdited = List.of(exercisesLocal);
                    expandedExerciseId = null;
                  });
                },
                icon: const Icon(Icons.edit),
              ),
        // EXERCISES LIST
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Exercises: "),
              if (exercisesEditable) ...[
                ReorderableListView(
                  shrinkWrap: true,
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final Exercise item = exercisesEdited.removeAt(oldIndex);
                      exercisesEdited.insert(newIndex, item);
                    });
                  },
                  children: [
                    for (int index = 0; index < exercisesEdited.length; index++)
                      ListTile(
                        key: ValueKey(exercisesEdited[index].id),
                        title: Text(
                            exercisesService.getExerciseDescriptionString(
                                exercisesEdited[index])[0]),
                        subtitle: Text(
                            exercisesService.getExerciseDescriptionString(
                                exercisesEdited[index])[1]),
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  exercisesEdited.removeAt(index);
                                });
                              },
                            ),
                            exercisesService.generateExercisePreviewButton(
                                context, exercisesEdited[index]),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateExerciseScreen(
                                      existingExercise: exercisesEdited[index],
                                      courseId: widget.lesson.courseId,
                                    ),
                                  ),
                                ).then((value) {
                                  if (value != null) {
                                    setState(() {
                                      exercisesEdited[index] =
                                          value as Exercise;
                                      exercisesLocal[index] = value;
                                    });
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (context) =>
                            PickExerciseScreen(exercises: exercisesEdited),
                      ),
                    )
                        .then((value) {
                      if (value != null) {
                        setState(() {
                          exercisesEdited.add(value as Exercise);
                        });
                      }
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add exercise"),
                ),
              ] else
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: exercisesLocal.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(exercisesService.getExerciseDescriptionString(
                          exercisesLocal[index])[0]),
                      subtitle: Text(
                          exercisesService.getExerciseDescriptionString(
                              exercisesLocal[index])[1]),
                      // onTap: () {
                      // setState(() {
                      //   if (expandedExerciseId == exercisesLocal[index].id) {
                      //     expandedExerciseId = null;
                      //   } else {
                      //     expandedExerciseId = exercisesLocal[index].id;
                      //   }
                      // });
                      // },
                      leading: exercisesService.generateExercisePreviewButton(
                          context, exercisesLocal[index]),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
