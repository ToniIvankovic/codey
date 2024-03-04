// ignore_for_file: file_names

import 'package:codey/models/entities/exercise.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class ExerciseSCWWidget extends StatefulWidget {
  const ExerciseSCWWidget({
    Key? key,
    required this.exercise,
    required this.onAnswerSelected,
    required this.statementArea,
  }) : super(key: key);

  final Exercise exercise;
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
    var gaps = widget.exercise.statementCode!.split('\\gap').length - 1;
    controllers = List<TextEditingController>.generate(
      gaps,
      (index) => TextEditingController(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var codeParts = widget.exercise.statementCode!.split('\\gap');
    var gaps = codeParts.length - 1;
    Widget codeArea = Padding(
      padding: const EdgeInsets.all(20.0),
      child: DottedBorder(
        borderType: BorderType.RRect,
        dashPattern: const [6, 3],
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              for (var i = 0; i < codeParts.length; i++) ...[
                Text(
                  codeParts[i],
                  style: const TextStyle(
                    fontFamily: 'courier new',
                    fontSize: 20.0,
                  ),
                ),
                if (i < gaps)
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        minWidth: widget.exercise.defaultGapLengths![i] * 20,
                        maxWidth:
                            widget.exercise.defaultGapLengths![i] * 20 * 2.5),
                    child: IntrinsicWidth(
                      stepWidth: 20.0,
                      child: TextField(
                        controller: controllers[i],
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
                  )
              ]
            ],
          ),
        ),
      ),
    );

    final statementOutput = Text(
      "> ${widget.exercise.statementOutput!}",
      style: const TextStyle(fontSize: 20.0),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.statementArea,
        codeArea,
        statementOutput,
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
}
