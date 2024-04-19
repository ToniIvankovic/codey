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
  late final ExerciseMC exercise;
  late final List<MapEntry<String, dynamic>> answerOptions;
  @override
  void initState() {
    super.initState();
    exercise = widget.exercise as ExerciseMC;
    answerOptions = exercise.answerOptions.entries.toList();
    answerOptions.shuffle();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.statementArea,
        widget.codeArea,
        widget.questionArea,
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 1,
          childAspectRatio: 4, // For square tiles
          children: answerOptions.map((option) {
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
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(selectedAnswer == option.key ? 1 : 0.5),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Center(
                    child: Text(
                      option.value,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
