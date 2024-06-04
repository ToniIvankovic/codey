// ignore_for_file: file_names

import 'package:codey/models/entities/exercise_LA.dart';
import 'package:codey/widgets/student/exercises/exercise_LA_puzzle_widget.dart';
import 'package:codey/widgets/student/exercises/exercise_LA_writing_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ExerciseLAWidget extends StatefulWidget {
  final ExerciseLA exercise;
  const ExerciseLAWidget({
    super.key,
    required this.exercise,
    required this.onAnswerSelected,
    required this.statementArea,
    // required this.questionArea,
    required this.changesEnabled,
  });

  final ValueChanged<String> onAnswerSelected;
  final Widget statementArea;
  // final Widget questionArea;
  final ValueListenable<bool> changesEnabled;

  @override
  State<ExerciseLAWidget> createState() => _ExerciseLAWidgetState();
}

class _ExerciseLAWidgetState extends State<ExerciseLAWidget> {
  bool writingMode = false;

  @override
  Widget build(BuildContext context) {
    final statementOutputArea = widget.exercise.statementOutput != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ispis:",
                style: TextStyle(fontSize: 20.0),
              ),
              Text(
                widget.exercise.statementOutput!
                    .replaceAll(" ", "·")
                    .replaceAll("\t", " ⇥ "),
                style: const TextStyle(fontSize: 18.0, fontFamily: "courier new"),
              ),
            ],
          )
        : const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (writingMode)
          ExerciseLAWritingWidget(
            exercise: widget.exercise,
            onAnswerSelected: widget.onAnswerSelected,
            statementArea: widget.statementArea,
            statementOutputArea: statementOutputArea,
            changesEnabled: widget.changesEnabled,
          )
        else
          ExerciseLAPuzzleWidget(
            exercise: widget.exercise,
            onAnswerSelected: widget.onAnswerSelected,
            statementArea: widget.statementArea,
            statementOutputArea: statementOutputArea,
            changesEnabled: widget.changesEnabled,
          ),
        if (widget.exercise.answerOptions != null &&
            widget.exercise.answerOptions!.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      writingMode = !writingMode;
                    });
                  },
                  child: Text(writingMode ? 'Slagalica' : 'Pisanje'),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
