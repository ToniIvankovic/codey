// ignore_for_file: file_names

import 'package:codey/models/entities/exercise_LA.dart';
import 'package:flutter/material.dart';

class ExerciseLAWritingWidget extends StatelessWidget {
  final ExerciseLA exercise;
  const ExerciseLAWritingWidget({
    super.key,
    required this.exercise,
    required this.onAnswerSelected,
    required this.statementArea,
    required this.codeArea,
    required this.questionArea,
  });

  final ValueChanged<String> onAnswerSelected;
  final Widget statementArea;
  final Widget codeArea;
  final Widget questionArea;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        statementArea,
        codeArea,
        questionArea,
        TextField(
          decoration: const InputDecoration(
            labelText: 'Answer',
          ),
          maxLines: null,
          minLines: 5,
          onChanged: (value) => onAnswerSelected(value),
        ),
      ],
    );
  }
}
