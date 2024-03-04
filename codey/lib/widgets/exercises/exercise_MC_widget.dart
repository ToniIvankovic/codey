// ignore_for_file: file_names

import 'package:codey/models/entities/exercise.dart';
import 'package:codey/models/entities/exercise_MC.dart';
import 'package:flutter/material.dart';

class ExerciseMCWidget extends StatefulWidget {
  const ExerciseMCWidget({
    Key? key,
    required this.exercise,
    required this.onAnswerSelected,
    required this.statementArea,
    required this.codeArea,
    required this.questionArea,
  }) : super(key: key);

  final Exercise exercise;
  final ValueChanged<String> onAnswerSelected;
  final Widget statementArea;
  final Widget codeArea;
  final Widget questionArea;

  @override
  State<ExerciseMCWidget> createState() => _ExerciseMCWidgetState();
}

class _ExerciseMCWidgetState extends State<ExerciseMCWidget> {
  String? selectedAnswer;
  @override
  Widget build(BuildContext context) {
    var exercise = widget.exercise as ExerciseMC;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.statementArea,
        widget.codeArea,
        widget.questionArea,
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          childAspectRatio: 2, // For square tiles
          children: exercise.answerOptions.entries.map((option) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedAnswer = option.key;
                });
                widget.onAnswerSelected(selectedAnswer!);
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selectedAnswer == option.key
                          ? Colors.black
                          : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(option.value),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        Text(exercise.correctAnswer,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
