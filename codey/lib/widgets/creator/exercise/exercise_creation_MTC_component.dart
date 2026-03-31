// ignore_for_file: file_names

import 'package:codey/models/entities/exercise_MTC.dart';
import 'package:codey/widgets/creator/exercise/exercise_creation_component.dart';
import 'package:flutter/material.dart';

class ExerciseCreationMTCComponent extends ExerciseCreationComponent {
  const ExerciseCreationMTCComponent({
    super.key,
    required super.formKey,
    required super.onChange,
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

  dynamic _packFields() {
    return {
      'answerOptionsList': [leftItems.toList(), rightItems.toList()],
    };
  }

  @override
  void initState() {
    super.initState();
    if (widget.existingExercise != null) {
      final ex = widget.existingExercise!;
      leftItems = List.of(ex.leftItems);
      rightItems = List.of(ex.rightItems);
      rowKeys = List.generate(leftItems.length, (i) => i.toString());
    }
  }

  void _addPair() {
    setState(() {
      leftItems.add('');
      rightItems.add('');
      rowKeys.add(DateTime.now().toIso8601String());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Parovi (lijevo → desno):'),
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
                      decoration: InputDecoration(labelText: 'Lijevo ${index + 1}'),
                      initialValue: leftItems[index],
                      onChanged: (value) {
                        setState(() => leftItems[index] = value);
                        widget.onChange(_packFields());
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Unesi pojam'
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
                      decoration: InputDecoration(labelText: 'Desno ${index + 1}'),
                      initialValue: rightItems[index],
                      onChanged: (value) {
                        setState(() => rightItems[index] = value);
                        widget.onChange(_packFields());
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Unesi pojam'
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
                        });
                        widget.onChange(_packFields());
                      },
                    ),
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
            label: const Text('Dodaj par'),
          ),
        ),
      ],
    );
  }
}
