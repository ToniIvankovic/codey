// ignore_for_file: file_names

import 'package:codey/models/entities/exercise.dart';
import 'package:flutter/material.dart';

class ExerciseSAWidget extends StatelessWidget {
  const ExerciseSAWidget({
    super.key,
    required this.exercise,
    required this.onAnswerSelected,
    required this.statementArea,
    required this.codeArea,
    required this.questionArea,
  });

  final Exercise exercise;
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
            labelText: 'Odgovor',
          ),
          maxLines: 1,
          onChanged: (value) => onAnswerSelected(value),
        ),
      ],
    );
  }
}
