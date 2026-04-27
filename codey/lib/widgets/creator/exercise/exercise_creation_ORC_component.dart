// ignore_for_file: file_names

import 'package:codey/models/entities/exercise_ORC.dart';
import 'package:codey/widgets/creator/exercise/exercise_creation_component.dart';
import 'package:flutter/material.dart';

class ExerciseCreationORCComponent extends ExerciseCreationComponent {
  const ExerciseCreationORCComponent({
    super.key,
    required super.formKey,
    required super.onChange,
    super.firstFocusNode,
    this.existingExercise,
  });

  final ExerciseORC? existingExercise;

  @override
  State<ExerciseCreationORCComponent> createState() =>
      _ExerciseCreationORCComponentState();
}

class _ExerciseCreationORCComponentState
    extends State<ExerciseCreationORCComponent> {
  List<String> lines = [''];
  List<String> lineKeys = ['0'];
  late final FocusNode _firstLineFocus;
  // Focus nodes for indices >= 1; index 0 uses _firstLineFocus.
  final List<FocusNode> _extraLineFocuses = [];

  FocusNode _lineFocus(int index) =>
      index == 0 ? _firstLineFocus : _extraLineFocuses[index - 1];

  int get _lineFocusCount => 1 + _extraLineFocuses.length;

  dynamic _packFields() {
    return {
      'answerOptionsList': [lines.where((l) => l.isNotEmpty).toList()],
    };
  }

  @override
  void initState() {
    super.initState();
    _firstLineFocus = widget.firstFocusNode ?? FocusNode();
    if (widget.existingExercise != null) {
      lines = List.of(widget.existingExercise!.answerOptions);
      lineKeys = List.generate(lines.length, (i) => i.toString());
    }
    while (_lineFocusCount < lines.length) {
      _extraLineFocuses.add(FocusNode());
    }
  }

  @override
  void dispose() {
    if (widget.firstFocusNode == null) {
      _firstLineFocus.dispose();
    }
    for (final node in _extraLineFocuses) {
      node.dispose();
    }
    super.dispose();
  }

  void _addLine() {
    setState(() {
      lines.add('');
      lineKeys.add(DateTime.now().toIso8601String());
      _extraLineFocuses.add(FocusNode());
    });
    widget.onChange(_packFields());
    _lineFocus(lines.length - 1).requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Code lines (in correct order):'),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: lines.length,
          itemBuilder: (context, index) {
            return Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    '${index + 1}.',
                    style: const TextStyle(fontFamily: 'courier new'),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    key: ValueKey('${lineKeys[index]}_$index'),
                    focusNode: _lineFocus(index),
                    decoration: InputDecoration(labelText: 'Line ${index + 1}'),
                    initialValue: lines[index],
                    style: const TextStyle(fontFamily: 'courier new'),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _addLine(),
                    onChanged: (value) {
                      setState(() {
                        lines[index] = value;
                      });
                      widget.onChange(_packFields());
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Enter code line'
                        : null,
                    onSaved: (value) {
                      setState(() {
                        lines[index] = value ?? '';
                      });
                      widget.onChange(_packFields());
                    },
                  ),
                ),
                if (index > 0)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        lines.removeAt(index);
                        lineKeys.removeAt(index);
                        _extraLineFocuses.removeAt(index - 1).dispose();
                      });
                      widget.onChange(_packFields());
                    },
                  ),
              ],
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: _addLine,
            icon: const Icon(Icons.add),
            label: const Text('Add line'),
          ),
        ),
      ],
    );
  }
}
