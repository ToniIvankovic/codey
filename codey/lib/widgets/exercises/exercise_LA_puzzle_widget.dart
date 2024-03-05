// ignore_for_file: file_names

import 'package:codey/models/entities/exercise_LA.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class ExerciseLAPuzzleWidget extends StatefulWidget {
  final ExerciseLA exercise;
  const ExerciseLAPuzzleWidget({
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
  State<ExerciseLAPuzzleWidget> createState() => _ExerciseLAPuzzleWidgetState();
}

class _ExerciseLAPuzzleWidgetState extends State<ExerciseLAPuzzleWidget> {
  static const pieceBorderRadius = 8.0;
  List<GestureDetector> answerParts = [];

  @override
  Widget build(BuildContext context) {
    final answerPartsWithNewlines = <Widget>[];
    //add a sizedBox after each answerPart that contains a newline
    for (var i = 0; i < answerParts.length; i++) {
      answerPartsWithNewlines.add(answerParts[i]);
      if (answerParts[i].child!.key.toString().contains('↵')) {
        answerPartsWithNewlines.add(const SizedBox(
          width: double.infinity,
        ));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.statementArea,
        widget.codeArea,
        widget.questionArea,
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            constraints: const BoxConstraints(minHeight: 150, maxHeight: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(pieceBorderRadius),
              color: Color.fromARGB(50, 200, 200, 200), // Set opacity value here
            ),
            child: DottedBorder(
              color: Colors.grey,
              strokeWidth: 2,
              dashPattern: const [6, 3],
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                          spacing: 8.0, // gap between adjacent chips
                          runSpacing: 4.0, // gap between lines
                          children: answerPartsWithNewlines),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 8.0, // gap between adjacent chips
            runSpacing: 4.0, // gap between lines
            children: widget.exercise.answerOptions.entries.map((entry) {
              final entryTextToDisplay = entry.value
                  .toString()
                  .replaceAll('\n', '↵')
                  .replaceAll('\r', '↵');

              var codePiece = Container(
                key: ValueKey(entryTextToDisplay),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(pieceBorderRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(entryTextToDisplay),
                ),
              );

              var detectorInAnswer = GestureDetector(
                key: ValueKey(entry.key),
                onTap: () {
                  setState(() {
                    answerParts.removeWhere(
                        (widget) => widget.key == ValueKey(entry.key));
                    updateAnswer();
                  });
                },
                child: codePiece,
              );

              var detectorInOptions = GestureDetector(
                key: ValueKey(entry.key),
                onTap: () {
                  // If the key is present in answerParts, return without handling the tap
                  if (answerParts
                      .any((piece) => piece.key == ValueKey(entry.key))) {
                    return;
                  }

                  setState(() {
                    answerParts.add(detectorInAnswer);
                    updateAnswer();
                  });
                },
                child: Opacity(
                  opacity: answerParts
                          .any((piece) => piece.key == ValueKey(entry.key))
                      ? 0.15
                      : 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(pieceBorderRadius),
                      color: answerParts
                              .any((piece) => piece.key == ValueKey(entry.key))
                          ? Colors.grey
                          : Colors.transparent,
                    ),
                    child: codePiece,
                  ),
                ),
              );
              return detectorInOptions;
            }).toList(),
          ),
        )
      ],
    );
  }

  void updateAnswer() {
    var joinedAnswer = answerParts.map((piece) {
      return widget.exercise.answerOptions[(piece.key as ValueKey).value];
    }).join();
    widget.onAnswerSelected(joinedAnswer);
  }
}
