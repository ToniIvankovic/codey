// ignore_for_file: file_names

import 'package:codey/models/entities/exercise_ORC.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ExerciseORCWidget extends StatefulWidget {
  final ExerciseORC exercise;
  final ValueChanged<List<int>> onAnswerSelected;
  final Widget statementArea;
  final ValueListenable<bool> changesEnabled;

  const ExerciseORCWidget({
    super.key,
    required this.exercise,
    required this.onAnswerSelected,
    required this.statementArea,
    required this.changesEnabled,
  });

  @override
  State<ExerciseORCWidget> createState() => _ExerciseORCWidgetState();
}

class _ExerciseORCWidgetState extends State<ExerciseORCWidget> {
  late List<int> _order; // indices into exercise.answerOptions

  @override
  void initState() {
    super.initState();
    _order = List.generate(widget.exercise.answerOptions.length, (i) => i);
    _order.shuffle();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onAnswerSelected(List.of(_order));
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (!widget.changesEnabled.value) return;
    setState(() {
      if (oldIndex < newIndex) newIndex -= 1;
      final item = _order.removeAt(oldIndex);
      _order.insert(newIndex, item);
    });
    widget.onAnswerSelected(List.of(_order));
  }

  @override
  Widget build(BuildContext context) {
    final lines = widget.exercise.answerOptions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: widget.statementArea,
        ),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          onReorder: _onReorder,
          itemCount: _order.length,
          itemBuilder: (context, listIndex) {
            final lineIndex = _order[listIndex];
            return Container(
              key: ValueKey(lineIndex),
              margin: const EdgeInsets.symmetric(vertical: 3.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(8.0),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: ListTile(
                dense: true,
                title: Text(
                  lines[lineIndex],
                  style: const TextStyle(
                      fontFamily: 'courier new', fontSize: 14.0),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
