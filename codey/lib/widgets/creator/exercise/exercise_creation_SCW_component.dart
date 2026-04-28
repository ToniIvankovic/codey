// ignore_for_file: file_names

import 'package:codey/models/entities/exercise.dart';
import 'package:codey/models/entities/exercise_SCW.dart';
import 'package:codey/widgets/creator/exercise/exercise_creation_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExerciseCreationSCWComponent extends ExerciseCreationComponent {
  const ExerciseCreationSCWComponent({
    super.key,
    required super.formKey,
    required super.onChange,
    super.firstFocusNode,
    this.existingExercise,
  });

  final Exercise? existingExercise;

  @override
  State<ExerciseCreationSCWComponent> createState() =>
      _ExerciseCreationSCWComponentState();
}

class _ExerciseCreationSCWComponentState
    extends State<ExerciseCreationSCWComponent> {
  final codeController = TextEditingController();
  String? statementCode;
  // List<int> defaultGapLengths = [];
  List<List<String>> answers = [];
  List<List<String>> answerKeys = [];
  final List<List<FocusNode>> _answerFocuses = [];
  int numberOfGaps = 0;
  bool? scwTextWrap;

  @override
  void dispose() {
    for (final gap in _answerFocuses) {
      for (final node in gap) {
        node.dispose();
      }
    }
    super.dispose();
  }

  dynamic _packFields() {
    List<int> defaultGapLengths = answers
        .map((answer) => answer[0])
        .map((answer) => answer.length)
        .toList();
    return {
      "statementCode": statementCode,
      "defaultGapLengths": defaultGapLengths,
      "correctAnswers":
          answers.map((answer) => List<String>.from(answer)).toList(),
      "scwTextWrap": scwTextWrap,
    };
  }

  @override
  void initState() {
    super.initState();
    if (widget.existingExercise is ExerciseSCW) {
      final ExerciseSCW exercise = widget.existingExercise as ExerciseSCW;
      statementCode = exercise.statementCode;
      codeController.text = statementCode!;
      numberOfGaps = statementCode!.split("\\gap").length - 1;
      answers = List.of(exercise.correctAnswers?.map((e) => List.of(e)) ?? []);
      answerKeys = List.generate(
          answers.length,
          (index) => List.generate(answers[index].length,
              (index) => DateTime.now().toIso8601String()));
      scwTextWrap = exercise.scwTextWrap;
    }
    for (final gap in answers) {
      _answerFocuses.add(List.generate(gap.length, (_) => FocusNode()));
    }
  }

  void _addAnswer(int index) {
    setState(() {
      answers[index].add("");
      answerKeys[index].add(DateTime.now().toIso8601String());
      _answerFocuses[index].add(FocusNode());
    });
    widget.onChange(_packFields());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.enter): () {
              if (_answerFocuses.isNotEmpty &&
                  _answerFocuses[0].isNotEmpty) {
                _answerFocuses[0][0].requestFocus();
              } else {
                FocusScope.of(context).unfocus();
              }
            },
          },
          child: TextFormField(
            focusNode: widget.firstFocusNode,
            minLines: 1,
            maxLines: 10,
            decoration: const InputDecoration(labelText: 'Statement code'),
            onChanged: (value) {
              numberOfGaps = value.split("\\gap").length - 1;
              setState(() {
                statementCode = value;
                while (answers.length < numberOfGaps) {
                  answers.add([""]);
                  answerKeys.add([DateTime.now().toIso8601String()]);
                  _answerFocuses.add([FocusNode()]);
                }
                while (answerKeys.length > numberOfGaps) {
                  answers.removeLast();
                  answerKeys.removeLast();
                  for (final node in _answerFocuses.removeLast()) {
                    node.dispose();
                  }
                }
              });
            },
            controller: codeController,
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter statement code'
                : null,
            onSaved: (value) {
              setState(() {
                statementCode = value;
              });
              widget.onChange(_packFields());
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: DropdownButtonFormField<bool?>(
            value: scwTextWrap,
            decoration: const InputDecoration(labelText: 'Text wrap'),
            items: const [
              DropdownMenuItem<bool?>(
                value: null,
                child: Text('Use course default'),
              ),
              DropdownMenuItem<bool?>(
                value: true,
                child: Text('Wrap text (no horizontal scroll)'),
              ),
              DropdownMenuItem<bool?>(
                value: false,
                child: Text('Scroll horizontally'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                scwTextWrap = value;
              });
              widget.onChange(_packFields());
            },
          ),
        ),
        TextButton.icon(
            onPressed: () {
              setState(() {
                numberOfGaps++;
                statementCode = "${statementCode ?? ''}\\gap";
                codeController.text = statementCode!;
                answers.add([""]);
                answerKeys.add([DateTime.now().toIso8601String()]);
                _answerFocuses.add([FocusNode()]);
              });
              widget.onChange(_packFields());
            },
            icon: const Icon(Icons.add),
            label: const Text("Add Gap")),
        for (var gapIndex = 0; gapIndex < numberOfGaps; gapIndex++) ...[
          Text("Gap ${gapIndex + 1}"),
          ListView.builder(
            shrinkWrap: true,
            itemCount: answers[gapIndex].length,
            itemBuilder: (context, index) {
              return Row(
                children: [
                  Expanded(
                    child: CallbackShortcuts(
                      bindings: {
                        const SingleActivator(LogicalKeyboardKey.enter): () {
                          if (index + 1 < _answerFocuses[gapIndex].length) {
                            _answerFocuses[gapIndex][index + 1].requestFocus();
                          } else if (gapIndex + 1 < _answerFocuses.length &&
                              _answerFocuses[gapIndex + 1].isNotEmpty) {
                            _answerFocuses[gapIndex + 1][0].requestFocus();
                          } else {
                            FocusScope.of(context).unfocus();
                          }
                        },
                      },
                      child: TextFormField(
                        key: ValueKey('${answerKeys[gapIndex][index]}_$index'),
                        focusNode: _answerFocuses[gapIndex][index],
                        initialValue: answers[gapIndex][index],
                        minLines: 1,
                        maxLines: 3,
                        decoration:
                            const InputDecoration(labelText: 'Correct answer:'),
                        onChanged: (value) {
                          setState(() {
                            answers[gapIndex][index] = value;
                          });
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter an answer'
                            : null,
                        onSaved: (value) {
                          setState(() {
                            answers[gapIndex][index] = value!;
                          });
                          widget.onChange(_packFields());
                        },
                      ),
                    ),
                  ),
                  if (index > 0)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          answers[gapIndex].removeAt(index);
                          answerKeys[gapIndex].removeAt(index);
                          _answerFocuses[gapIndex].removeAt(index).dispose();
                        });
                        widget.onChange(_packFields());
                      },
                    ),
                ],
              );
            },
          ),
          ElevatedButton(
            onPressed: () {
              _addAnswer(gapIndex);
            },
            child: const Text('Add Answer'),
          ),
        ],
      ],
    );
  }
}
