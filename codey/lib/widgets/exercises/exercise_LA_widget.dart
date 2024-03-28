// ignore_for_file: file_names

import 'package:codey/models/entities/exercise_LA.dart';
import 'package:codey/widgets/exercises/exercise_LA_puzzle_widget.dart';
import 'package:codey/widgets/exercises/exercise_LA_writing_widget.dart';
import 'package:flutter/material.dart';

class ExerciseLAWidget extends StatefulWidget {
  final ExerciseLA exercise;
  const ExerciseLAWidget({
    super.key,
    required this.exercise,
    required this.onAnswerSelected,
    required this.statementArea,
    // required this.questionArea,
  });

  final ValueChanged<String> onAnswerSelected;
  final Widget statementArea;
  // final Widget questionArea;

  @override
  State<ExerciseLAWidget> createState() => _ExerciseLAWidgetState();
}

class _ExerciseLAWidgetState extends State<ExerciseLAWidget> {
  bool writingMode = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (writingMode)
          ExerciseLAWritingWidget(
            exercise: widget.exercise,
            onAnswerSelected: widget.onAnswerSelected,
            statementArea: widget.statementArea,
            // questionArea: widget.questionArea
          )
        else
          ExerciseLAPuzzleWidget(
            exercise: widget.exercise,
            onAnswerSelected: widget.onAnswerSelected,
            statementArea: widget.statementArea,
            // questionArea: widget.questionArea
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
                  child: Text(writingMode ? 'Puzzle mode' : 'Writing mode'),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
