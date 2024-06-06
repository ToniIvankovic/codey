// ignore_for_file: file_names

import 'package:codey/models/entities/exercise.dart';
import 'package:codey/models/entities/exercise_MC.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ExerciseMCWidget extends StatefulWidget {
  const ExerciseMCWidget({
    Key? key,
    required this.exercise,
    required this.onAnswerSelected,
    required this.statementArea,
    required this.codeArea,
    required this.questionArea,
    required this.changesEnabled,
    required this.correctAnswerSignal,
  }) : super(key: key);

  final Exercise exercise;
  final ValueChanged<String> onAnswerSelected;
  final Widget statementArea;
  final Widget codeArea;
  final Widget questionArea;
  final ValueListenable<bool> changesEnabled;
  final ValueListenable<bool?> correctAnswerSignal;

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
        for (var option in answerOptions)
          Builder(builder: (context) {
            Color color;
            if (selectedAnswer == option.key &&
                widget.correctAnswerSignal.value == true) {
              color = Theme.of(context).colorScheme.primary;
            } else if (selectedAnswer == option.key &&
                widget.correctAnswerSignal.value == false) {
              color = Theme.of(context).colorScheme.error;
            } else if (selectedAnswer == option.key) {
              color = Theme.of(context).colorScheme.onSurface.withOpacity(1);
            } else {
              color =
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.5);
            }

            return GestureDetector(
              onTap: widget.changesEnabled.value
                  ? () {
                      setState(() {
                        selectedAnswer = option.key;
                      });
                      widget.onAnswerSelected(selectedAnswer!);
                    }
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: color,
                      width: selectedAnswer == option.key ? 3 : 1.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).colorScheme.inverseSurface,
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Text(
                        option.value,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onInverseSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
