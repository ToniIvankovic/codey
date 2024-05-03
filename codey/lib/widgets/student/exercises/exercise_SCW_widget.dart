// ignore_for_file: file_names

import 'package:codey/models/entities/exercise_SCW.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class ExerciseSCWWidget extends StatefulWidget {
  const ExerciseSCWWidget({
    Key? key,
    required this.exercise,
    required this.onAnswerSelected,
    required this.statementArea,
  }) : super(key: key);

  final ExerciseSCW exercise;
  final ValueChanged<List<String>> onAnswerSelected;
  final Widget statementArea;

  @override
  // ignore: library_private_types_in_public_api
  _ExerciseSCWWidgetState createState() => _ExerciseSCWWidgetState();
}

class _ExerciseSCWWidgetState extends State<ExerciseSCWWidget> {
  late List<TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    var gaps = widget.exercise.statementCode.split('\\gap').length - 1;
    controllers = List<TextEditingController>.generate(
      gaps,
      (index) => TextEditingController(),
    );
  }

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
                style:
                    const TextStyle(fontSize: 18.0, fontFamily: "courier new"),
              ),
            ],
          )
        : const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.statementArea,
        _generateCodeArea(),
        statementOutputArea,
      ],
    );
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _generateCodeArea() {
    var textLines = widget.exercise.statementCode.split("\n");
    var codeParts = widget.exercise.statementCode.split('\\gap');
    var gaps = codeParts.length - 1;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: DottedBorder(
          borderType: BorderType.RRect,
          dashPattern: const [6, 6],
          radius: const Radius.circular(10.0),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 1.5,
                minWidth: MediaQuery.of(context).size.width,
              ),
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._generateLinesWithGaps(textLines),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _generateLinesWithGaps(List<String> lines) {
    int usedLines = 0;
    List<Widget> widgets = [];
    for (var line in lines) {
      if (!line.contains('\\gap')) {
        widgets.add(
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  line,
                  style: const TextStyle(
                    fontFamily: 'courier new',
                    fontSize: 20.0,
                  ),
                ),
              ),
            ],
          ),
        );
        continue;
      }

      var parts = line.split('\\gap');
      var rowWidgets = <Widget>[];
      for (var part in parts) {
        if (part.isNotEmpty) {
          rowWidgets.add(
            Text(
              part,
              style: const TextStyle(
                fontFamily: 'courier new',
                fontSize: 20.0,
              ),
            ),
          );
        }
        if (usedLines < controllers.length) {
          rowWidgets.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 8.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minWidth: widget.exercise.defaultGapLengths[usedLines] * 18,
                    maxWidth: widget.exercise.defaultGapLengths[usedLines] *
                        18 *
                        2.5),
                child: IntrinsicWidth(
                  stepWidth: 18.0,
                  child: TextField(
                    controller: controllers[usedLines],
                    onChanged: (value) {
                      var answer = controllers.map((e) => e.text).toList();
                      widget.onAnswerSelected(answer);
                    },
                    style: const TextStyle(
                      fontFamily: 'courier new',
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
            ),
          );
          usedLines++;
        }
      }
      widgets.add(Row(children: rowWidgets));
    }
    return widgets;
  }
}
