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
    required this.statementOutputArea,
  });

  final ValueChanged<String> onAnswerSelected;
  final Widget statementArea;
  final Widget statementOutputArea;

  @override
  State<ExerciseLAPuzzleWidget> createState() => _ExerciseLAPuzzleWidgetState();
}

class _ExerciseLAPuzzleWidgetState extends State<ExerciseLAPuzzleWidget> {
  static const pieceBorderRadius = 8.0;
  List<GestureDetector> answerParts = [];
  List<MapEntry<String, dynamic>> answerOptions = [];
  int newlineTabCounter = 0;

  @override
  void initState() {
    super.initState();
    answerOptions = widget.exercise.answerOptions!.entries.toList();
    answerOptions.shuffle();
  }

  @override
  Widget build(BuildContext context) {
    const double spaceBetweenPiecesVertical = 8.0;
    const double spaceBetweenPiecesHorizontal = 4.0;
    final answerPartsWithNewlines = <Widget>[];
    //add a sizedBox after each answerPart that contains a newline
    var currentRow = <Widget>[];
    for (var i = 0; i < answerParts.length; i++) {
      currentRow.add(
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: spaceBetweenPiecesHorizontal / 2),
          child: answerParts[i],
        ),
      );
      if (answerParts[i].key.toString().contains('↵')) {
        answerPartsWithNewlines.add(
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: spaceBetweenPiecesVertical / 2),
            child: Row(
              children: List.of(currentRow),
            ),
          ),
        );
        currentRow = <Widget>[];
      }
    }
    if (currentRow.isNotEmpty) {
      answerPartsWithNewlines.add(
        Padding(
          padding: const EdgeInsets.symmetric(
              vertical: spaceBetweenPiecesVertical / 2),
          child: Row(
            children: List.of(currentRow),
          ),
        ),
      );
    }

    const double initialCodeAreaHeight = 150;
    const double maxCodeAreaHeight = 400;
    const double borderWidth = 2.0;
    const double paddingAroundCodeArea = 8.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.statementArea,
        // widget.questionArea,
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            constraints: BoxConstraints(
              minHeight: initialCodeAreaHeight,
              maxHeight: maxCodeAreaHeight,
              minWidth: MediaQuery.of(context).size.width,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
            ),
            child: DottedBorder(
              borderType: BorderType.RRect,
              color:
                  Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
              radius: const Radius.circular(10.0),
              strokeWidth: borderWidth,
              dashPattern: const [6, 6],
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(paddingAroundCodeArea),
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: initialCodeAreaHeight -
                          2 * paddingAroundCodeArea -
                          2 * borderWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: answerPartsWithNewlines,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        widget.statementOutputArea,
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8.0, // gap between adjacent chips
                  runSpacing: 4.0, // gap between lines
                  children: answerOptions.map((entry) {
                    //TODO: delete newline in code pieces?
                    final entryTextToDisplay = entry.value
                        .toString()
                        .replaceAll('\n', '↵')
                        .replaceAll('\r', '↵')
                        .replaceAll(' ', '·');

                    var codePiece = Container(
                      key: ValueKey(entryTextToDisplay),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .onBackground
                              .withOpacity(0.5),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(pieceBorderRadius),
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.7),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          entryTextToDisplay,
                          style: const TextStyle(fontFamily: 'courier new'),
                        ),
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
                        opacity: answerParts.any(
                                (piece) => piece.key == ValueKey(entry.key))
                            ? 0.1
                            : 1.0,
                        child: codePiece,
                      ),
                    );
                    return detectorInOptions;
                  }).toList(),
                ),
              ),
              //NEWLINE and TAB buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                child: Column(
                  children: [
                    _generateNewlineDetector(),
                    _generateTabDetector(),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  GestureDetector _generateNewlineDetector() {
    newlineTabCounter++;
    int currentValue = newlineTabCounter;
    return GestureDetector(
      onTap: () {
        var detectorInAnswer = GestureDetector(
          key: ValueKey('↵ $currentValue'),
          onTap: () {
            setState(() {
              answerParts.removeWhere(
                (widget) => widget.key == ValueKey('↵ $currentValue'),
              );
              updateAnswer();
            });
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(pieceBorderRadius),
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
            ),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('↵', style: TextStyle(fontFamily: 'courier new')),
            ),
          ),
        );
        setState(() {
          answerParts.add(detectorInAnswer);
          updateAnswer();
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(pieceBorderRadius),
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text(
              '↵',
              style: TextStyle(fontSize: 20.0, fontFamily: 'courier new'),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _generateTabDetector() {
    newlineTabCounter++;
    int currentValue = newlineTabCounter;
    return GestureDetector(
      onTap: () {
        var detectorInAnswer = GestureDetector(
          key: ValueKey('⇥ $currentValue'),
          onTap: () {
            setState(() {
              answerParts.removeWhere(
                (widget) => widget.key == ValueKey('⇥ $currentValue'),
              );
              updateAnswer();
            });
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(pieceBorderRadius),
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
            ),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                ' ⇥  ',
                style: TextStyle(fontFamily: 'courier new'),
              ),
            ),
          ),
        );
        setState(() {
          answerParts.add(detectorInAnswer);
          updateAnswer();
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(pieceBorderRadius),
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            child: Text(
              '⇥',
              style: TextStyle(fontSize: 20.0, fontFamily: 'courier new'),
            ),
          ),
        ),
      ),
    );
  }

  void updateAnswer() {
    var joinedAnswer = answerParts.map((piece) {
      if (piece.key.toString().contains('↵')) {
        return '\n';
      }
      if (piece.key.toString().contains('⇥')) {
        return '\t';
      }
      return widget.exercise.answerOptions![(piece.key as ValueKey).value];
    }).join();
    widget.onAnswerSelected(joinedAnswer);
  }
}
