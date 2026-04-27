// ignore_for_file: file_names

import 'package:codey/models/entities/exercise_MTC.dart';
import 'package:codey/widgets/creator/exercise/exercise_creation_component.dart';
import 'package:flutter/material.dart';

class ExerciseCreationMTCComponent extends ExerciseCreationComponent {
  const ExerciseCreationMTCComponent({
    super.key,
    required super.formKey,
    required super.onChange,
    super.firstFocusNode,
    this.existingExercise,
  });

  final ExerciseMTC? existingExercise;

  @override
  State<ExerciseCreationMTCComponent> createState() =>
      _ExerciseCreationMTCComponentState();
}

class _ExerciseCreationMTCComponentState
    extends State<ExerciseCreationMTCComponent> {
  // Parallel lists — leftItems[i] pairs with rightItems[i]
  List<String> leftItems = [''];
  List<String> rightItems = [''];
  List<String> rowKeys = ['0'];
  late final FocusNode _firstLeftFocus;
  // Focus nodes for left indices >= 1; index 0 uses _firstLeftFocus.
  final List<FocusNode> _extraLeftFocuses = [];
  final List<FocusNode> _rightFocuses = [];

  FocusNode _leftFocus(int index) =>
      index == 0 ? _firstLeftFocus : _extraLeftFocuses[index - 1];

  dynamic _packFields() {
    return {
      'answerOptionsList': [leftItems.toList(), rightItems.toList()],
    };
  }

  @override
  void initState() {
    super.initState();
    _firstLeftFocus = widget.firstFocusNode ?? FocusNode();
    if (widget.existingExercise != null) {
      final ex = widget.existingExercise!;
      leftItems = List.of(ex.leftItems);
      rightItems = List.of(ex.rightItems);
      rowKeys = List.generate(leftItems.length, (i) => i.toString());
    }
    while (_extraLeftFocuses.length < leftItems.length - 1) {
      _extraLeftFocuses.add(FocusNode());
    }
    while (_rightFocuses.length < leftItems.length) {
      _rightFocuses.add(FocusNode());
    }
  }

  @override
  void dispose() {
    if (widget.firstFocusNode == null) {
      _firstLeftFocus.dispose();
    }
    for (final node in _extraLeftFocuses) {
      node.dispose();
    }
    for (final node in _rightFocuses) {
      node.dispose();
    }
    super.dispose();
  }

  void _addPair() {
    setState(() {
      leftItems.add('');
      rightItems.add('');
      rowKeys.add(DateTime.now().toIso8601String());
      _extraLeftFocuses.add(FocusNode());
      _rightFocuses.add(FocusNode());
    });
    widget.onChange(_packFields());
    _leftFocus(leftItems.length - 1).requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Pairs (left → right):'),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: leftItems.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      key: ValueKey('left_${rowKeys[index]}_$index'),
                      focusNode: _leftFocus(index),
                      decoration: InputDecoration(labelText: 'Left ${index + 1}'),
                      initialValue: leftItems[index],
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          _rightFocuses[index].requestFocus(),
                      onChanged: (value) {
                        setState(() => leftItems[index] = value);
                        widget.onChange(_packFields());
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter term'
                          : null,
                      onSaved: (value) {
                        setState(() => leftItems[index] = value ?? '');
                        widget.onChange(_packFields());
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.arrow_forward),
                  ),
                  Expanded(
                    child: TextFormField(
                      key: ValueKey('right_${rowKeys[index]}_$index'),
                      focusNode: _rightFocuses[index],
                      decoration: InputDecoration(labelText: 'Right ${index + 1}'),
                      initialValue: rightItems[index],
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _addPair(),
                      onChanged: (value) {
                        setState(() => rightItems[index] = value);
                        widget.onChange(_packFields());
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter term'
                          : null,
                      onSaved: (value) {
                        setState(() => rightItems[index] = value ?? '');
                        widget.onChange(_packFields());
                      },
                    ),
                  ),
                  if (index > 0)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          leftItems.removeAt(index);
                          rightItems.removeAt(index);
                          rowKeys.removeAt(index);
                          _extraLeftFocuses.removeAt(index - 1).dispose();
                          _rightFocuses.removeAt(index).dispose();
                        });
                        widget.onChange(_packFields());
                      },
                    )
                  else
                    const SizedBox(width: 48, height: 48),
                ],
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: _addPair,
            icon: const Icon(Icons.add),
            label: const Text('Add pair'),
          ),
        ),
      ],
    );
  }
}
