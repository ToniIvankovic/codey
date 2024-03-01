import 'package:codey/models/entities/exercise.dart';
import 'package:codey/models/entities/exercise_LA.dart';
import 'package:codey/models/entities/exercise_MC.dart';
import 'package:codey/models/entities/exercise_SA.dart';
import 'package:codey/services/exercises_service.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class SingleExerciseWidget extends StatefulWidget {
  const SingleExerciseWidget({
    Key? key,
    required this.exercisesService,
    required this.onSessionFinished,
  }) : super(key: key);

  final ExercisesService exercisesService;
  final VoidCallback onSessionFinished;

  @override
  State<SingleExerciseWidget> createState() => _SingleExerciseWidgetState();
}

class _SingleExerciseWidgetState extends State<SingleExerciseWidget> {
  bool? isCorrectResponse;
  dynamic answer;
  bool enableCheck = false;
  Exercise? exercise;

  @override
  void initState() {
    super.initState();
    exercise = widget.exercisesService.currentExercise;
  }

  @override
  Widget build(BuildContext context) {
    if (exercise == null) {
      widget.onSessionFinished();
      return const Text("No exercises");
    }

    ElevatedButton checkNextButton = buildCheckNextButton();
    var codeArea;
    if (exercise!.statementCode?.isEmpty == false) {
      codeArea = Padding(
        padding: const EdgeInsets.all(20.0),
        child: DottedBorder(
          borderType: BorderType.RRect,
          dashPattern: const [6, 3],
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              exercise!.statementCode!,
              style: const TextStyle(
                fontFamily: 'courier new',
                fontSize: 20.0,
              ),
            ),
          ),
        ),
      );
    } else {
      codeArea = SizedBox.shrink();
    }

    var questionArea;
    if (exercise!.question?.isEmpty == false) {
      questionArea =
          Text(exercise!.question!, style: const TextStyle(fontSize: 20.0));
    } else {
      questionArea = SizedBox.shrink();
    }

    final statementArea = Text(
        '${exercise!.statement} '
        '(${exercise!.id}, difficulty: ${exercise!.difficulty})',
        style: const TextStyle(fontSize: 20.0));

    // single exercise, button
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              statementArea,
              codeArea,
              questionArea,
              if (exercise is ExerciseMC)
                ExerciseMCWidget(
                  key: ValueKey(exercise!.id),
                  exercise: exercise!,
                  onAnswerSelected: (answer) {
                    setState(() {
                      this.answer = answer;
                      enableCheck = true;
                    });
                  },
                ),
              if (exercise is ExerciseSA)
                ExerciseSAWidget(
                    key: ValueKey(exercise!.id),
                    exercise: exercise!,
                    onAnswerSelected: (answer) {
                      setState(() {
                        this.answer = answer;
                        enableCheck = true;
                      });
                    }),
              if (exercise is ExerciseLA)
                ExerciseLAWidget(
                    key: ValueKey(exercise!.id),
                    exercise: exercise!,
                    onAnswerSelected: (answer) {
                      setState(() {
                        this.answer = answer;
                        //TODO make this work
                        if (answer.isNotEmpty) {
                          enableCheck = true;
                        }
                      });
                    }),
            ],
          ),
        ),
        checkNextButton,
      ],
    );
  }

  ElevatedButton buildCheckNextButton() {
    ElevatedButton button;
    //If the exercise isn't answered yet, show the check button (active if anything is enterd)
    if (isCorrectResponse == null) {
      button = ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: null),
        onPressed: enableCheck
            ? () {
                setState(() {
                  enableCheck = false;
                });
                widget.exercisesService.checkAnswer(exercise!, answer).then(
                  (value) {
                    setState(() {
                      isCorrectResponse = value;
                    });
                  },
                );
              }
            : null,
        child: const Text('CHECK'),
      );
    } else {
      //If the exercise is answered, show the next button
      button = ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isCorrectResponse == true
              ? const Color.fromARGB(255, 123, 224, 127)
              : Colors.red,
        ),
        onPressed: () {
          setState(() {
            exercise = widget.exercisesService.getNextExercise();
            isCorrectResponse = null;
            enableCheck = false;
          });
        },
        child: const Text('NEXT'),
      );
    }
    return button;
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
          minLines: 5,
          onChanged: (value) => onAnswerSelected(value),
        ),
      ],
    );
  }
}
