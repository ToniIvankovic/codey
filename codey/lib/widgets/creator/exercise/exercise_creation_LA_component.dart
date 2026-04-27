// ignore_for_file: file_names

import 'package:codey/models/entities/exercise.dart';
import 'package:codey/models/entities/exercise_LA.dart';
import 'package:codey/widgets/creator/exercise/exercise_creation_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExerciseCreationLAComponent extends ExerciseCreationComponent {
  const ExerciseCreationLAComponent({
    super.key,
    required super.formKey,
    required super.onChange,
    super.firstFocusNode,
    this.existingExercise,
  });

  final Exercise? existingExercise;

  @override
  State<ExerciseCreationLAComponent> createState() =>
      _ExerciseCreationSAComponentState();
}

class _ExerciseCreationSAComponentState
    extends State<ExerciseCreationLAComponent> {
  final TextEditingController _optionController = TextEditingController();
  List<String?> answers = [null];
  List<String> answerKeys = ["1"];
  List<String> options = [];
  String? option;
  late final FocusNode _firstAnswerFocus;
  // Focus nodes for indices >= 1; index 0 uses _firstAnswerFocus.
  final List<FocusNode> _extraAnswerFocuses = [];
  final FocusNode _pieceFocus = FocusNode();

  FocusNode _answerFocus(int index) =>
      index == 0 ? _firstAnswerFocus : _extraAnswerFocuses[index - 1];

  int get _answerFocusCount => 1 + _extraAnswerFocuses.length;

  @override
  void dispose() {
    if (widget.firstFocusNode == null) {
      _firstAnswerFocus.dispose();
    }
    for (final node in _extraAnswerFocuses) {
      node.dispose();
    }
    _pieceFocus.dispose();
    super.dispose();
  }

  void _addPiece() {
    if (option == null || option!.isEmpty) return;
    setState(() {
      options.add(option!);
      option = null;
      _optionController.clear();
    });
    widget.onChange(_packFields());
    _pieceFocus.requestFocus();
  }

  dynamic _packFields() {
    return {
      "correctAnswers":
          answers.where((element) => element != null).toList().cast<String>(),
      "answerOptionsList": [options],
    };
  }

  @override
  void initState() {
    super.initState();
    _firstAnswerFocus = widget.firstFocusNode ?? FocusNode();
    if (widget.existingExercise is ExerciseLA) {
      final ExerciseLA exercise = widget.existingExercise as ExerciseLA;
      answers = exercise.correctAnswers;
      answerKeys = List.generate(answers.length, (index) => index.toString());
      options = List.of(exercise.answerOptions ?? []);
    }
    while (_answerFocusCount < answers.length) {
      _extraAnswerFocuses.add(FocusNode());
    }
  }

  void _addAnswer() {
    setState(() {
      answers.add('');
      answerKeys.add(DateTime.now().toIso8601String());
      _extraAnswerFocuses.add(FocusNode());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                        if (index + 1 < _answerFocusCount) {
                          _answerFocus(index + 1).requestFocus();
                        } else {
                          FocusScope.of(context).unfocus();
                        }
                      },
                    },
                    child: TextFormField(
                      key: ValueKey('${answerKeys[index]}_$index'),
                      focusNode: _answerFocus(index),
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
                        _extraAnswerFocuses.removeAt(index - 1).dispose();
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
        const Text('Possible Puzzle Pieces:'),
        Row(
          children: [
            TextButton.icon(
                onPressed: option != null && option!.isNotEmpty
                    ? _addPiece
                    : null,
                icon: const Icon(Icons.add),
                label: const Text('Add Piece')),
            Expanded(
              child: TextFormField(
                focusNode: _pieceFocus,
                minLines: 1,
                maxLines: 1,
                decoration: const InputDecoration(labelText: 'Piece:'),
                controller: _optionController,
                onChanged: (value) {
                  setState(() {
                    option = value;
                  });
                },
                onFieldSubmitted: (_) => _addPiece(),
              ),
            )
          ],
        ),
        Wrap(
          children: [
            for (String option in options)
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(option),
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            options.remove(option);
                          });
                          widget.onChange(_packFields());
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
