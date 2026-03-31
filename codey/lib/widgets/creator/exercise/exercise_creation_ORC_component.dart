// ignore_for_file: file_names

import 'package:codey/models/entities/exercise_ORC.dart';
import 'package:codey/widgets/creator/exercise/exercise_creation_component.dart';
import 'package:flutter/material.dart';

class ExerciseCreationORCComponent extends ExerciseCreationComponent {
  const ExerciseCreationORCComponent({
    super.key,
    required super.formKey,
    required super.onChange,
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

  dynamic _packFields() {
    return {
      'answerOptionsList': [lines.where((l) => l.isNotEmpty).toList()],
    };
  }

  @override
  void initState() {
    super.initState();
    if (widget.existingExercise != null) {
      lines = List.of(widget.existingExercise!.answerOptions);
      lineKeys = List.generate(lines.length, (i) => i.toString());
    }
  }

  void _addLine() {
    setState(() {
      lines.add('');
      lineKeys.add(DateTime.now().toIso8601String());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Redci koda (u ispravnom redoslijedu):'),
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
                    decoration: InputDecoration(labelText: 'Redak ${index + 1}'),
                    initialValue: lines[index],
                    style: const TextStyle(fontFamily: 'courier new'),
                    onChanged: (value) {
                      setState(() {
                        lines[index] = value;
                      });
                      widget.onChange(_packFields());
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Unesi redak koda'
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
            label: const Text('Dodaj redak'),
          ),
        ),
      ],
    );
  }
}
