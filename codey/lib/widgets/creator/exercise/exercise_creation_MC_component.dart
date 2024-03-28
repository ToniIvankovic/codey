// ignore_for_file: file_names

import 'package:codey/models/entities/exercise_MC.dart';
import 'package:codey/widgets/creator/exercise/exercise_creation_component.dart';
import 'package:flutter/material.dart';

class ExerciseCreationMCComponent extends ExerciseCreationComponent {
  const ExerciseCreationMCComponent({
    super.key,
    required super.formKey,
    required super.onChange,
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

  dynamic _packFields() {
    return {
      "id": widget.existingExercise?.id ?? 0,
      "statementCode": statementCode,
      "question": question,
      "answerOptions": answerOptions,
      "correctAnswer": correctAnswer,
    };
  }

  @override
  void initState() {
    super.initState();
    if (widget.existingExercise != null) {
      statementCode = widget.existingExercise!.statementCode;
      question = widget.existingExercise!.question;
      answerOptions =
          widget.existingExercise!.answerOptions.cast<String, String>();
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
              setState(() {
                statementCode = value;
              });
              widget.onChange(_packFields());
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
            setState(() {
              question = value;
            });
            widget.onChange(_packFields());
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
              setState(() {
                answerOptions[option] = value!;
              });
              widget.onChange(_packFields());
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
          onSaved: (String? value) {
            setState(() {
              correctAnswer = value;
            });
            widget.onChange(_packFields());
          },
          validator: (value) =>
              value == null ? 'Please select an answer' : null,
        ),
      ],
    );
  }
}
