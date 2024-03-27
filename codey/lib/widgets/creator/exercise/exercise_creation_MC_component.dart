// ignore_for_file: file_names

import 'package:codey/models/entities/exercise.dart';
import 'package:codey/models/entities/exercise_MC.dart';
import 'package:codey/widgets/creator/exercise/exercise_creation_component.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ExerciseCreationMCComponent extends ExerciseCreationComponent {
  ExerciseCreationMCComponent({
    super.key,
    required super.formKey,
    this.existingExercise,
  });

  final ExerciseMC? existingExercise;
  @override
  State<ExerciseCreationMCComponent> createState() =>
      _ExerciseCreationMCComponentState();
}

class _ExerciseCreationMCComponentState
    extends State<ExerciseCreationMCComponent> {
  String? statementCode;
  String? question;
  Map<String, String> answerOptions = {};
  String? correctAnswer;

  Exercise createExercise({
    int? difficulty,
    String? statement,
    String? statementOutput,
    String? specificTip,
  }) {
    return ExerciseMC(
      id: widget.existingExercise?.id ?? 0,
      difficulty: difficulty,
      statement: statement,
      statementOutput: statementOutput,
      specificTip: specificTip,
      statementCode: statementCode!,
      question: question!,
      answerOptions: answerOptions,
      correctAnswer: correctAnswer!,
    );
  }

  @override
  void initState() {
    super.initState();
    widget.createExercise = createExercise;
    if (widget.existingExercise != null) {
      statementCode = widget.existingExercise!.statementCode;
      question = widget.existingExercise!.question;
      answerOptions = widget.existingExercise!.answerOptions.cast<String, String>();
      correctAnswer = widget.existingExercise!.correctAnswer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FormField(builder: (FormFieldState<String> state) {
          return TextFormField(
            minLines: 1,
            maxLines: 10,
            decoration: const InputDecoration(labelText: 'Statement code'),
            initialValue: statementCode,
            onSaved: (value) {
              statementCode = value;
            },
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter statement code'
                : null,
          );
        }),
        TextFormField(
          minLines: 1,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'Question'),
          initialValue: question,
          onSaved: (value) {
            question = value;
          },
          validator: (value) =>
              value == null || value.isEmpty ? 'Please enter a question' : null,
        ),
        for (var option in ["A", "B", "C"])
          TextFormField(
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(labelText: 'Answer option $option'),
            initialValue: answerOptions[option],
            onSaved: (value) {
              answerOptions[option] = value!;
            },
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter an option'
                : null,
          ),
        //dropdown for correct answer A/B/C
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Correct answer'),
          value: correctAnswer,
          items: const [
            DropdownMenuItem(value: "A", child: Text("A")),
            DropdownMenuItem(value: "B", child: Text("B")),
            DropdownMenuItem(value: "C", child: Text("C")),
          ],
          onChanged: (String? value) {
            setState(() {
              correctAnswer = value;
            });
          },
          validator: (value) =>
              value == null ? 'Please select an answer' : null,
        ),
      ],
    );
  }
}
