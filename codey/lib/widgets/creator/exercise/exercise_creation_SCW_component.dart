// ignore_for_file: file_names

import 'package:codey/models/entities/exercise.dart';
import 'package:codey/models/entities/exercise_SCW.dart';
import 'package:codey/widgets/creator/exercise/exercise_creation_component.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ExerciseCreationSCWComponent extends ExerciseCreationComponent {
  ExerciseCreationSCWComponent({
    super.key,
    required super.formKey,
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
  int numberOfGaps = 0;

  Exercise createExercise({
    int? difficulty,
    String? statement,
    String? statementOutput,
    String? specificTip,
  }) {
    List<int> defaultGapLengths = answers
        .map((answer) => answer[0])
        .map((answer) => answer.length)
        .toList();
    return ExerciseSCW(
      id: widget.existingExercise?.id ?? 0,
      difficulty: difficulty,
      statement: statement,
      statementOutput: statementOutput!,
      statementCode: statementCode!,
      specificTip: specificTip,
      defaultGapLengths: defaultGapLengths,
      correctAnswers:
          answers.map((answer) => List<String>.from(answer)).toList(),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.createExercise = createExercise;
    if (widget.existingExercise != null) {
      final ExerciseSCW exercise = widget.existingExercise as ExerciseSCW;
      statementCode = exercise.statementCode;
      codeController.text = statementCode!;
      numberOfGaps = statementCode!.split("\\gap").length - 1;
      answers = List.of(exercise.correctAnswers?.map((e) => List.of(e)) ?? []);
      answerKeys = List.generate(
          answers.length,
          (index) => List.generate(answers[index].length,
              (index) => DateTime.now().toIso8601String()));
    }
  }

  void _addAnswer(int index) {
    setState(() {
      answers[index].add("");
      answerKeys[index].add(DateTime.now().toIso8601String()); // Add this line
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          minLines: 1,
          maxLines: 10,
          decoration: const InputDecoration(labelText: 'Statement code'),
          onChanged: (value) {
            numberOfGaps = value.split("\\gap").length - 1;
            setState(() {
              statementCode = value;
              while (answers.length < numberOfGaps) {
                answers.add([]);
                answerKeys.add([DateTime.now().toIso8601String()]);
              }
              while (answerKeys.length > numberOfGaps) {
                answers.removeLast();
                answerKeys.removeLast();
              }
            });
          },
          controller: codeController,
          validator: (value) => value == null || value.isEmpty
              ? 'Please enter statement code'
              : null,
        ),
        TextButton.icon(
            onPressed: () {
              setState(() {
                numberOfGaps++;
                statementCode = "${statementCode ?? ''}\\gap";
                codeController.text = statementCode!;
                answers.add([""]);
                answerKeys.add([DateTime.now().toIso8601String()]);
              });
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
                    child: TextFormField(
                      key: ValueKey('${answerKeys[gapIndex][index]}_$index'),
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
                    ),
                  ),
                  if (index > 0)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          answers[gapIndex].removeAt(index);
                          answerKeys[gapIndex].removeAt(index);
                        });
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
