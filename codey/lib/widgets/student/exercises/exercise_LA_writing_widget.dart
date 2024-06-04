// ignore_for_file: file_names

import 'package:codey/models/entities/exercise_LA.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ExerciseLAWritingWidget extends StatelessWidget {
  final ExerciseLA exercise;
  const ExerciseLAWritingWidget({
    super.key,
    required this.exercise,
    required this.onAnswerSelected,
    required this.statementArea,
    required this.statementOutputArea,
    required this.changesEnabled,
  });

  final ValueChanged<String> onAnswerSelected;
  final Widget statementArea;
  final Widget statementOutputArea;
  final ValueListenable<bool> changesEnabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        statementArea,
        // questionArea,
        TextField(
          decoration: const InputDecoration(
            labelText: 'Odgovor',
          ),
          maxLines: null,
          minLines: 5,
          onChanged: (value) => onAnswerSelected(value),
          enabled: changesEnabled.value,
        ),
        statementOutputArea,
      ],
    );
  }
}
