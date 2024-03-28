// ignore_for_file: file_names

import 'package:codey/models/entities/exercise.dart';
import 'package:codey/models/entities/exercise_LA.dart';
import 'package:codey/widgets/creator/exercise/exercise_creation_component.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ExerciseCreationLAComponent extends ExerciseCreationComponent {
  ExerciseCreationLAComponent({
    super.key,
    required super.formKey,
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

  Exercise createExercise({
    int? difficulty,
    String? statement,
    String? statementOutput,
    String? specificTip,
  }) {
    return ExerciseLA(
      id: widget.existingExercise?.id ?? 0,
      difficulty: difficulty,
      statement: statement,
      statementOutput: statementOutput,
      specificTip: specificTip,
      correctAnswers:
          answers.where((element) => element != null).toList().cast<String>(),
      answerOptions: {
        for (var i = 0; i < options.length; i++) i.toString(): options[i]
      },
    );
  }

  @override
  void initState() {
    super.initState();
    widget.createExercise = createExercise;
    if (widget.existingExercise != null) {
      final ExerciseLA exercise = widget.existingExercise as ExerciseLA;
      answers = exercise.correctAnswers;
      answerKeys = List.generate(answers.length, (index) => index.toString());
      options = List.of(exercise.answerOptions?.values.toList() ?? []);
    }
  }

  void _addAnswer() {
    setState(() {
      answers.add('');
      answerKeys.add(DateTime.now().toIso8601String()); // Add this line
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
                  child: TextFormField(
                    key: ValueKey('${answerKeys[index]}_$index'),
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
                  ),
                ),
                if (index > 0)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        answers.removeAt(index);
                        answerKeys.removeAt(index);
                      });
                    },
                  ),
              ],
            );
          },
        ),
        ElevatedButton(
          onPressed: () {
            _addAnswer();
          },
          child: const Text('Add Answer'),
        ),
        const Text('Possible Puzzle Pieces:'),
        Row(
          children: [
            TextButton.icon(
                onPressed: option != null && option!.isNotEmpty
                    ? () {
                        setState(() {
                          options.add(option!);
                          option = null;
                          _optionController.clear();
                        });
                      }
                    : null,
                icon: const Icon(Icons.add),
                label: const Text('Add Piece')),
            Expanded(
              child: TextFormField(
                minLines: 1,
                maxLines: 1,
                decoration: const InputDecoration(labelText: 'Piece:'),
                controller: _optionController,
                onChanged: (value) {
                  setState(() {
                    option = value;
                  });
                },
              ),
            )
          ],
        ),
        Row(
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
