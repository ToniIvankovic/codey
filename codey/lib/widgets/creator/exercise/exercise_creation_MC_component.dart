// ignore_for_file: file_names

import 'package:codey/models/entities/exercise_MC.dart';
import 'package:codey/widgets/creator/exercise/exercise_creation_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExerciseCreationMCComponent extends ExerciseCreationComponent {
  const ExerciseCreationMCComponent({
    super.key,
    required super.formKey,
    required super.onChange,
    super.firstFocusNode,
    this.existingExercise,
  });

  final ExerciseMC? existingExercise;
  @override
  State<ExerciseCreationMCComponent> createState() =>
      _ExerciseCreationMCComponentState();
}

class _ExerciseCreationMCComponentState
    extends State<ExerciseCreationMCComponent> {
  String? statementCode;
  String? question;
  Map<String, String?> answerOptions = {};
  String? correctAnswer;
  final _questionFocus = FocusNode();
  final _aFocus = FocusNode();
  final _bFocus = FocusNode();
  final _cFocus = FocusNode();
  final _dFocus = FocusNode();

  @override
  void dispose() {
    _questionFocus.dispose();
    _aFocus.dispose();
    _bFocus.dispose();
    _cFocus.dispose();
    _dFocus.dispose();
    super.dispose();
  }

  dynamic _packFields() {
    return {
      "id": widget.existingExercise?.id ?? 0,
      "statementCode": statementCode,
      "question": question,
      "answerOptions": answerOptions,
      "correctAnswer": correctAnswer,
    };
  }

  @override
  void initState() {
    super.initState();
    if (widget.existingExercise != null) {
      statementCode = widget.existingExercise!.statementCode;
      question = widget.existingExercise!.question;
      answerOptions =
          widget.existingExercise!.answerOptions.cast<String, String?>();
      correctAnswer = widget.existingExercise!.correctAnswer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final optionFocuses = {
      'A': _aFocus,
      'B': _bFocus,
      'C': _cFocus,
      'D': _dFocus,
    };
    final nextOptionFocus = {
      'A': _bFocus,
      'B': _cFocus,
      'C': _dFocus,
      'D': null,
    };
    return Column(
      children: [
        FormField(builder: (FormFieldState<String> state) {
          return CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.enter): () =>
                  _questionFocus.requestFocus(),
            },
            child: TextFormField(
              focusNode: widget.firstFocusNode,
              minLines: 1,
              maxLines: 10,
              decoration: const InputDecoration(labelText: 'Statement code'),
              initialValue: statementCode,
              onSaved: (value) {
                setState(() {
                  statementCode = value;
                });
                widget.onChange(_packFields());
              },
              // validator: (value) => value == null || value.isEmpty
              //     ? 'Please enter statement code'
              //     : null,
            ),
          );
        }),
        CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.enter): () =>
                _aFocus.requestFocus(),
          },
          child: TextFormField(
            focusNode: _questionFocus,
            minLines: 1,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Question'),
            initialValue: question,
            onSaved: (value) {
              setState(() {
                question = value;
              });
              widget.onChange(_packFields());
            },
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter a question'
                : null,
          ),
        ),
        for (var option in ["A", "B", "C", "D"])
          CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.enter): () {
                final next = nextOptionFocus[option];
                if (next != null) {
                  next.requestFocus();
                } else {
                  FocusScope.of(context).unfocus();
                }
              },
            },
            child: TextFormField(
              focusNode: optionFocuses[option],
              minLines: 1,
              maxLines: 3,
              decoration: InputDecoration(labelText: 'Answer option $option'),
              initialValue: answerOptions[option],
              onSaved: (value) {
                if (value == null || value.isEmpty) {
                  value = null;
                }
                setState(() {
                  answerOptions[option] = value;
                });
                widget.onChange(_packFields());
              },
              validator: (value) =>
                  (["A", "B"].contains(option)) && (value == null || value.isEmpty)
                      ? 'Please enter an option'
                      : null,
            ),
          ),
        //dropdown for correct answer A/B/C
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Correct answer'),
          value: correctAnswer,
          items: const [
            DropdownMenuItem(value: "A", child: Text("A")),
            DropdownMenuItem(value: "B", child: Text("B")),
            DropdownMenuItem(value: "C", child: Text("C")),
            DropdownMenuItem(value: "D", child: Text("D")),
          ],
          onChanged: (String? value) {
            setState(() {
              correctAnswer = value;
            });
          },
          onSaved: (String? value) {
            setState(() {
              correctAnswer = value;
            });
            widget.onChange(_packFields());
          },
          validator: (value) =>
              value == null ? 'Please select an answer' : null,
        ),
      ],
    );
  }
}
