import 'package:codey/models/entities/exercise.dart';
import 'package:codey/models/entities/exercise_LA.dart';
import 'package:codey/models/entities/exercise_MC.dart';
import 'package:codey/models/entities/exercise_SA.dart';
import 'package:codey/models/entities/exercise_SCW.dart';
import 'package:codey/services/exercises_service.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

import 'exercise_LA_widget.dart';
import 'exercise_MC_widget.dart';
import 'exercise_SA_widget.dart';
import 'exercise_SCW_widget.dart';

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
  int repeatCount = 0;

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

    ElevatedButton checkNextButton = _buildCheckNextButton();
    // single exercise, button
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
              statementArea: _buildStaticStatementArea(),
              codeArea: _buildStaticCodeArea(),
              questionArea: _buildStaticQuestionArea(),
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
              },
              statementArea: _buildStaticStatementArea(),
              codeArea: _buildStaticCodeArea(),
              questionArea: _buildStaticQuestionArea(),
            ),
          if (exercise is ExerciseLA)
            ExerciseLAWidget(
              key: ValueKey(exercise!.id),
              exercise: exercise!,
              onAnswerSelected: (answer) {
                setState(() {
                  this.answer = answer;
                  enableCheck = answer.isNotEmpty;
                });
              },
              statementArea: _buildStaticStatementArea(),
              codeArea: _buildStaticCodeArea(),
              questionArea: _buildStaticQuestionArea(),
            ),
          if (exercise is ExerciseSCW)
            ExerciseSCWWidget(
              key: ValueKey(exercise!.id + 100 * repeatCount),
              exercise: exercise!,
              onAnswerSelected: (answer) {
                setState(() {
                  this.answer = answer;
                  enableCheck = answer.isNotEmpty &&
                      answer.every((element) => element.isNotEmpty);
                });
              },
              statementArea: _buildStaticStatementArea(),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
            child: checkNextButton,
          ),
        ],
      ),
    );
  }

  ElevatedButton _buildCheckNextButton() {
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
        child: const Padding(
          padding: EdgeInsets.all(10.0),
          child: Text('CHECK'),
        ),
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
            repeatCount++;
          });
        },
        child: const Padding(
          padding: EdgeInsets.all(10.0),
          child: Text('NEXT'),
        ),
      );
    }
    return button;
  }

  Widget _buildStaticStatementArea() {
    Widget statementArea = Text(
        '${exercise!.statement} '
        '(${exercise!.id}, difficulty: ${exercise!.difficulty})',
        style: const TextStyle(fontSize: 20.0));
    return statementArea;
  }

  Widget _buildStaticQuestionArea() {
    Widget questionArea;
    if (exercise!.question?.isEmpty == false) {
      questionArea =
          Text(exercise!.question!, style: const TextStyle(fontSize: 20.0));
    } else {
      questionArea = const SizedBox.shrink();
    }
    return questionArea;
  }

  Widget _buildStaticCodeArea() {
    Widget codeArea;
    if (exercise!.statementCode?.isEmpty == false) {
      codeArea = Padding(
        padding: const EdgeInsets.all(20.0),
        child: DottedBorder(
          borderType: BorderType.RRect,
          dashPattern: const [6, 3],
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Text(
                  exercise!.statementCode!,
                  style: const TextStyle(
                    fontFamily: 'courier new',
                    fontSize: 20.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      codeArea = const SizedBox.shrink();
    }
    return codeArea;
  }
}
