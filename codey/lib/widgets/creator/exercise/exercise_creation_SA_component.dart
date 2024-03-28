// ignore_for_file: file_names

import 'package:codey/models/entities/exercise_SA.dart';
import 'package:codey/widgets/creator/exercise/exercise_creation_component.dart';
import 'package:flutter/material.dart';

class ExerciseCreationSAComponent extends ExerciseCreationComponent {
  const ExerciseCreationSAComponent({
    super.key,
    required super.formKey,
    required super.onChange,
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

  void _addAnswer() {
    setState(() {
      answers.add('');
      answerKeys.add(DateTime.now().toIso8601String()); // Add this line
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
        if (!raisesError) ...[
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
                      onSaved: (value) {
                        setState(() {
                          answers[index] = value;
                        });
                        widget.onChange(_packFields());
                      },
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
                        widget.onChange(_packFields());
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
