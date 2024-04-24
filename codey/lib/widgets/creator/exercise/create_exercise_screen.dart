import 'package:codey/models/entities/exercise.dart';
import 'package:codey/models/entities/exercise_LA.dart';
import 'package:codey/models/entities/exercise_MC.dart';
import 'package:codey/models/entities/exercise_SA.dart';
import 'package:codey/models/entities/exercise_SCW.dart';
import 'package:codey/models/entities/exercise_type.dart';
import 'package:codey/models/exceptions/no_changes_exception.dart';
import 'package:codey/services/exercises_service.dart';
import 'package:codey/widgets/creator/exercise/exercise_creation_LA_component.dart';
import 'package:codey/widgets/creator/exercise/exercise_creation_SCW_component.dart';
import 'package:codey/widgets/creator/exercise/exercise_creation_component.dart';
import 'package:codey/widgets/student/exercises/single_exercise_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'exercise_creation_MC_component.dart';
import 'exercise_creation_SA_component.dart';

class CreateExerciseScreen extends StatefulWidget {
  const CreateExerciseScreen({
    super.key,
    this.existingExercise,
  });

  final Exercise? existingExercise;
  @override
  State<CreateExerciseScreen> createState() => _CreateExerciseScreenState();
}

class _CreateExerciseScreenState extends State<CreateExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  int? difficulty;
  String? statement;
  ExerciseType? type;
  String? statementOutput;
  String? specificTip;
  dynamic innerFields;

  @override
  void initState() {
    super.initState();
    type = widget.existingExercise?.type;
    difficulty = widget.existingExercise?.difficulty;
    statement = widget.existingExercise?.statement;
    statementOutput = widget.existingExercise?.statementOutput;
    specificTip = widget.existingExercise?.specificTip;
  }

  Exercise createExercise() {
    if (type == ExerciseType.MC) {
      return ExerciseMC(
        id: widget.existingExercise?.id ?? 0,
        difficulty: difficulty,
        statement: statement,
        statementOutput: statementOutput,
        specificTip: specificTip,
        statementCode: innerFields['statementCode'],
        question: innerFields['question'],
        answerOptions: innerFields['answerOptions'],
        correctAnswer: innerFields['correctAnswer'],
      );
    } else if (type == ExerciseType.SA) {
      return ExerciseSA(
        id: widget.existingExercise?.id ?? 0,
        difficulty: difficulty,
        statement: statement,
        statementOutput: statementOutput,
        specificTip: specificTip,
        correctAnswers: innerFields['correctAnswers']!.cast<String>(),
        statementCode: innerFields['statementCode'],
        question: innerFields['question'],
        raisesError: innerFields['raisesError'],
      );
    } else if (type == ExerciseType.LA) {
      return ExerciseLA(
        id: widget.existingExercise?.id ?? 0,
        difficulty: difficulty,
        statement: statement,
        statementOutput: statementOutput,
        specificTip: specificTip,
        correctAnswers: innerFields['correctAnswers'].cast<String>(),
        answerOptions: innerFields['answerOptions'].cast<String, String>(),
      );
    } else if (type == ExerciseType.SCW) {
      return ExerciseSCW(
        id: widget.existingExercise?.id ?? 0,
        difficulty: difficulty,
        statement: statement,
        statementCode: innerFields['statementCode'],
        statementOutput: statementOutput,
        defaultGapLengths: innerFields['defaultGapLengths'],
        specificTip: specificTip,
        correctAnswers: innerFields['correctAnswers'],
      );
    } else {
      throw Exception('Invalid exercise type');
    }
  }

  @override
  Widget build(BuildContext context) {
    ExerciseCreationComponent? exerciseCreationComponent;
    if (type == ExerciseType.MC) {
      exerciseCreationComponent = ExerciseCreationMCComponent(
          formKey: _formKey,
          existingExercise: widget.existingExercise as ExerciseMC?,
          onChange: (innerFields) {
            setState(() {
              this.innerFields = innerFields;
            });
          });
    } else if (type == ExerciseType.SA) {
      exerciseCreationComponent = ExerciseCreationSAComponent(
          formKey: _formKey,
          existingExercise: widget.existingExercise as ExerciseSA?,
          onChange: (innerFields) {
            setState(() {
              this.innerFields = innerFields;
            });
          });
    } else if (type == ExerciseType.LA) {
      exerciseCreationComponent = ExerciseCreationLAComponent(
          formKey: _formKey,
          existingExercise: widget.existingExercise,
          onChange: (innerFields) {
            setState(() {
              this.innerFields = innerFields;
            });
          });
    } else if (type == ExerciseType.SCW) {
      exerciseCreationComponent = ExerciseCreationSCWComponent(
          formKey: _formKey,
          existingExercise: widget.existingExercise,
          onChange: (innerFields) {
            setState(() {
              this.innerFields = innerFields;
            });
          });
    } else {
      exerciseCreationComponent = null;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create exercise'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField<ExerciseType>(
                  decoration: const InputDecoration(labelText: 'Type'),
                  value: type,
                  onChanged: (newValue) {
                    setState(() {
                      type = newValue;
                    });
                  },
                  items: ExerciseType.values.map((ExerciseType value) {
                    return DropdownMenuItem<ExerciseType>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onSaved: (value) {
                    setState(() {
                      type = value;
                    });
                  },
                ),
                // DIFFICULTY
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Difficulty'),
                  initialValue: widget.existingExercise?.difficulty.toString(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a difficulty';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      setState(() {
                        difficulty = int.parse(value);
                      });
                    }
                  },
                ),
                // STATEMENT
                TextFormField(
                  minLines: 1,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Statement'),
                  initialValue: widget.existingExercise?.statement,
                  onSaved: (value) {
                    setState(() {
                      if (value != null && value.isNotEmpty) {
                        statement = value;
                      } else {
                        statement = null;
                      }
                    });
                  },
                ),
                // STATEMENT OUTPUT
                TextFormField(
                  minLines: 1,
                  maxLines: 5,
                  decoration:
                      const InputDecoration(labelText: 'Statement output'),
                  initialValue: widget.existingExercise?.statementOutput,
                  onSaved: (value) {
                    setState(() {
                      if (value != null && value.isNotEmpty) {
                        statementOutput = value;
                      } else {
                        statementOutput = null;
                      }
                    });
                  },
                ),
                // SPECIFIC TIP
                TextFormField(
                  minLines: 1,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Specific tip'),
                  initialValue: widget.existingExercise?.specificTip,
                  onSaved: (value) {
                    setState(() {
                      if (value != null && value.isNotEmpty) {
                        specificTip = value;
                      } else {
                        specificTip = null;
                      }
                    });
                  },
                ),
                exerciseCreationComponent ?? const SizedBox.shrink(),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: () {
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }

                              _formKey.currentState!.save();
                              Exercise exercise = createExercise();
                              final exercisesService =
                                  context.read<ExercisesService>();
                              exercisesService
                                  .startMockExerciseSession(exercise);
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
                            child: const Text("Preview exercise")),
                      ),
                      widget.existingExercise == null
                          ? ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  Exercise exercise = createExercise();
                                  final exercisesService =
                                      context.read<ExercisesService>();
                                  exercisesService
                                      .createExercise(exercise)
                                      .then((value) =>
                                          Navigator.of(context).pop(value));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Exercise created successfully'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Create'),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  Exercise exercise = createExercise();
                                  final exercisesService =
                                      context.read<ExercisesService>();
                                  exercisesService
                                      .updateExercise(exercise)
                                      .then((value) {
                                    Navigator.of(context).pop(value);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Changes saved'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  }).catchError((error) {
                                    if (error is NoChangesException) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('No changes made'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                      Navigator.of(context).pop();
                                    }
                                  });
                                }
                              },
                              child: const Text('Update')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
