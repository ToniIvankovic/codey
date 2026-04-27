// ignore_for_file: file_names

import 'package:codey/models/entities/exercise_SA.dart';
import 'package:codey/widgets/creator/exercise/exercise_creation_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExerciseCreationSAComponent extends ExerciseCreationComponent {
  const ExerciseCreationSAComponent({
    super.key,
    required super.formKey,
    required super.onChange,
    super.firstFocusNode,
    this.existingExercise,
  });

  final ExerciseSA? existingExercise;
  @override
  State<ExerciseCreationSAComponent> createState() =>
      _ExerciseCreationSAComponentState();
}

class _ExerciseCreationSAComponentState
    extends State<ExerciseCreationSAComponent> {
  String? statementCode;
  String? question;
  List<String?> answers = [null];
  List<String> answerKeys = ["1"];
  bool raisesError = false;
  final _questionFocus = FocusNode();
  final List<FocusNode> _answerFocuses = [FocusNode()];

  @override
  void dispose() {
    _questionFocus.dispose();
    for (final node in _answerFocuses) {
      node.dispose();
    }
    super.dispose();
  }

  void _addAnswer() {
    setState(() {
      answers.add('');
      answerKeys.add(DateTime.now().toIso8601String());
      _answerFocuses.add(FocusNode());
    });
    widget.onChange(_packFields());
  }

  dynamic _packFields() {
    return {
      "statementCode": statementCode,
      "question": question,
      "correctAnswers": raisesError
          ? []
          : answers.where((element) => element != null).toList().cast<String>(),
      "raisesError": raisesError ? true : null,
    };
  }

  @override
  void initState() {
    super.initState();
    if (widget.existingExercise != null) {
      statementCode = widget.existingExercise!.statementCode;
      question = widget.existingExercise!.question;
      answers =
          widget.existingExercise!.correctAnswers?.map((e) => e).toList() ??
              [null];
      answerKeys = List.generate(answers.length, (index) {
        return (index + 1).toString();
      });
      raisesError = widget.existingExercise!.raisesError ?? false;
      while (_answerFocuses.length < answers.length) {
        _answerFocuses.add(FocusNode());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FormField(builder: (FormFieldState<String> state) {
          return CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.enter): () =>
                  _questionFocus.requestFocus(),
            },
            child: TextFormField(
              focusNode: widget.firstFocusNode,
              minLines: 1,
              maxLines: 10,
              decoration: const InputDecoration(labelText: 'Statement code'),
              initialValue: statementCode,
              onSaved: (value) {
                setState(() {
                  statementCode = value;
                });
                widget.onChange(_packFields());
              },
              // validator: (value) => value == null || value.isEmpty
              //     ? 'Please enter statement code'
              //     : null,
            ),
          );
        }),
        CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.enter): () {
              if (_answerFocuses.isNotEmpty && !raisesError) {
                _answerFocuses[0].requestFocus();
              } else {
                FocusScope.of(context).unfocus();
              }
            },
          },
          child: TextFormField(
            focusNode: _questionFocus,
            minLines: 1,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Question'),
            initialValue: question,
            onSaved: (value) {
              setState(() {
                question = value;
              });
              widget.onChange(_packFields());
            },
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter a question'
                : null,
          ),
        ),
        if (!raisesError) ...[
          ListView.builder(
            shrinkWrap: true,
            itemCount: answers.length,
            itemBuilder: (context, index) {
              return Row(
                children: [
                  Expanded(
                    child: CallbackShortcuts(
                      bindings: {
                        const SingleActivator(LogicalKeyboardKey.enter): () {
                          if (index + 1 < _answerFocuses.length) {
                            _answerFocuses[index + 1].requestFocus();
                          } else {
                            FocusScope.of(context).unfocus();
                          }
                        },
                      },
                      child: TextFormField(
                        key: ValueKey('${answerKeys[index]}_$index'),
                        focusNode: _answerFocuses[index],
                        minLines: 1,
                        maxLines: 3,
                        decoration:
                            const InputDecoration(labelText: 'Correct answer:'),
                        initialValue: answers[index],
                        onChanged: (value) {
                          setState(() {
                            answers[index] = value;
                          });
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter an answer'
                            : null,
                        onSaved: (value) {
                          setState(() {
                            answers[index] = value;
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
                          answers.removeAt(index);
                          answerKeys.removeAt(index);
                          _answerFocuses.removeAt(index).dispose();
                        });
                        widget.onChange(_packFields());
                      },
                    ),
                ],
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                _addAnswer();
              },
              child: const Text('Add Answer'),
            ),
          ),
        ],
        CheckboxListTile(
          title: const Text('Raises Error'),
          value: raisesError,
          onChanged: (value) {
            setState(() {
              raisesError = value ?? false;
              if (raisesError == false && answers.isEmpty) {
                _addAnswer();
              }
            });
            widget.onChange(_packFields());
          },
        ),
      ],
    );
  }
}
