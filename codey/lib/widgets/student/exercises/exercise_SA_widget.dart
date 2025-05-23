// ignore_for_file: file_names

import 'package:codey/models/entities/exercise.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ExerciseSAWidget extends StatelessWidget {
  const ExerciseSAWidget({
    super.key,
    required this.exercise,
    required this.onAnswerSelected,
    required this.statementArea,
    required this.codeArea,
    required this.questionArea,
    required this.changesEnabled,
  });

  final Exercise exercise;
  final ValueChanged<String> onAnswerSelected;
  final Widget statementArea;
  final Widget codeArea;
  final Widget questionArea;
  final ValueListenable<bool> changesEnabled;

  @override
  Widget build(BuildContext context) {
    final statementOutputArea = exercise.statementOutput != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ispis:",
                style: TextStyle(fontSize: 20.0),
              ),
              Text(
                exercise.statementOutput!
                    .replaceAll(" ", "·")
                    .replaceAll("\t", " ⇥ "),
                style:
                    const TextStyle(fontSize: 18.0, fontFamily: "courier new"),
              ),
            ],
          )
        : const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        statementArea,
        codeArea,
        statementOutputArea,
        questionArea,
        TextField(
          decoration: const InputDecoration(
            labelText: 'Odgovor',
          ),
          onChanged: onAnswerSelected,
          minLines: 1,
          maxLines: 1,
          readOnly: !changesEnabled.value,
        ),
      ],
    );
  }
}
