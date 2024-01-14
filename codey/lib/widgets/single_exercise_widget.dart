import 'package:codey/models/exercise.dart';
import 'package:codey/models/exercise_LA.dart';
import 'package:codey/models/exercise_MC.dart';
import 'package:codey/models/exercise_SA.dart';
import 'package:codey/services/exercises_service.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class SingleExerciseWidget extends StatefulWidget {
  const SingleExerciseWidget({
    Key? key,
    required this.exercisesService,
  }) : super(key: key);

  final ExercisesService exercisesService;

  @override
  State<SingleExerciseWidget> createState() => _SingleExerciseWidgetState();
}

class _SingleExerciseWidgetState extends State<SingleExerciseWidget> {
  bool? correct;
  dynamic answer;

  @override
  Widget build(BuildContext context) {
    Exercise? exercise = widget.exercisesService.currentExercise;
    if (exercise == null) {
      return const Text('No exercises');
    }
    // single exercise, button
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
            //single exercise generic components (text, code...) + specific for exercise type
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                      '${exercise.statement} '
                      '(${exercise.id}, difficulty: ${exercise.difficulty})',
                      style: const TextStyle(fontSize: 20.0)),
                  if (exercise.statementCode?.isEmpty == false)
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        dashPattern: const [6, 3],
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            exercise.statementCode!,
                            style: const TextStyle(
                              fontFamily: 'courier new',
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (exercise.question?.isEmpty == false)
                    Text(exercise.question!,
                        style: const TextStyle(fontSize: 20.0)),
                  if (exercise is ExerciseMC)
                    ExerciseMCWidget(
                      key: ValueKey(exercise.id),
                      exercise: exercise,
                      onAnswerSelected: (answer) {
                        setState(() {
                          this.answer = answer;
                        });
                      },
                    ),
                  if (exercise is ExerciseSA)
                    ExerciseSAWidget(
                        key: ValueKey(exercise.id),
                        exercise: exercise,
                        onAnswerSelected: (answer) {
                          setState(() {
                            this.answer = answer;
                          });
                        }),
                  if (exercise is ExerciseLA)
                    ExerciseLAWidget(
                        key: ValueKey(exercise.id),
                        exercise: exercise,
                        onAnswerSelected: (answer) {
                          setState(() {
                            this.answer = answer;
                          });
                        }),
                ],
              ),
            )),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: correct == true
                ? const Color.fromARGB(255, 123, 224, 127)
                : correct == false
                    ? Colors.red
                    : null,
          ),
          onPressed: correct == null
              ? () {
                  widget.exercisesService.checkAnswer(exercise!, answer).then(
                    (value) {
                      setState(() {
                        correct = value;
                      });
                    },
                  );
                }
              : () {
                  setState(() {
                    exercise = widget.exercisesService.getNextExercise();
                    correct = null;
                  });
                },
          child: Text(correct == null ? 'CHECK' : 'NEXT'),
        ),
      ],
    );
  }
}

class ExerciseMCWidget extends StatefulWidget {
  const ExerciseMCWidget({
    Key? key,
    required this.exercise,
    required this.onAnswerSelected,
  }) : super(key: key);

  final Exercise exercise;
  final ValueChanged<String> onAnswerSelected;

  @override
  State<ExerciseMCWidget> createState() => _ExerciseMCWidgetState();
}

class _ExerciseMCWidgetState extends State<ExerciseMCWidget> {
  String? selectedAnswer;
  @override
  Widget build(BuildContext context) {
    var exercise = widget.exercise as ExerciseMC;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          childAspectRatio: 2, // For square tiles
          children: exercise.answerOptions.entries.map((option) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedAnswer = option.key;
                });
                widget.onAnswerSelected(selectedAnswer!);
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selectedAnswer == option.key
                          ? Colors.black
                          : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(option.value),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        Text(exercise.correctAnswer,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class ExerciseSAWidget extends StatelessWidget {
  const ExerciseSAWidget({
    super.key,
    required this.exercise,
    required this.onAnswerSelected,
  });

  final Exercise exercise;
  final ValueChanged<String> onAnswerSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'Answer',
          ),
          maxLines: 1,
          onChanged: (value) => onAnswerSelected(value),
        ),
      ],
    );
  }
}

class ExerciseLAWidget extends StatelessWidget {
  final Exercise exercise;
  const ExerciseLAWidget({
    super.key,
    required this.exercise,
    required this.onAnswerSelected,
  });

  final ValueChanged<String> onAnswerSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'Answer',
          ),
          maxLines: null,
          onChanged: (value) => onAnswerSelected(value),
        ),
      ],
    );
  }
}
