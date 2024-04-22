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
      return const Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    // single exercise, button
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (exercise is ExerciseMC)
                ExerciseMCWidget(
                  key: ValueKey(exercise!.id + 100 * repeatCount),
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
                  key: ValueKey(exercise!.id + 100 * repeatCount),
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
                  key: ValueKey(exercise!.id + 100 * repeatCount),
                  exercise: exercise! as ExerciseLA,
                  onAnswerSelected: (answer) {
                    setState(() {
                      this.answer = answer;
                      enableCheck = answer.isNotEmpty;
                    });
                  },
                  statementArea: _buildStaticStatementArea(),
                  // questionArea: _buildStaticQuestionArea(),
                ),
              if (exercise is ExerciseSCW)
                ExerciseSCWWidget(
                  key: ValueKey(exercise!.id + 100 * repeatCount),
                  exercise: exercise! as ExerciseSCW,
                  onAnswerSelected: (answer) {
                    setState(() {
                      this.answer = answer;
                      enableCheck = answer.isNotEmpty &&
                          answer.every((element) => element.isNotEmpty);
                    });
                  },
                  statementArea: _buildStaticStatementArea(),
                ),
            ],
          ),
        ),
        if (isCorrectResponse == null) _buildCheckButton(),
        if (isCorrectResponse != null) _buildNextButtonArea(),
      ],
    );
  }

  Widget _buildCheckButton() {
    return Positioned(
      bottom: 0,
      child: Container(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
          maxWidth: MediaQuery.of(context).size.width,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
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
                child: Text('PROVJERA'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButtonArea() {
    var correctAnswer = widget.exercisesService.getCorrectAnswer(exercise!);
    var textColor = TextStyle(
      color: isCorrectResponse == true
          ? Theme.of(context).colorScheme.onSecondary
          : Theme.of(context).colorScheme.onError,
    );
    return Positioned(
      bottom: 0,
      child: Container(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
          maxWidth: MediaQuery.of(context).size.width,
        ),
        color: isCorrectResponse == true
            ? Theme.of(context).colorScheme.inversePrimary.withOpacity(0.95)
            : Theme.of(context).colorScheme.errorContainer.withOpacity(0.9),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isCorrectResponse == true ? 'Točno!' : 'Netočno...',
                style: textColor.copyWith(
                  fontSize: 20.0,
                ),
              ),
              if (correctAnswer != null) ...[
                Text(
                  'Točan odgovor:',
                  style: textColor.copyWith(
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  correctAnswer,
                  style: textColor.copyWith(
                    fontSize: 16.0,
                  ),
                ),
              ],
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCorrectResponse == true
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () {
                      setState(() {
                        exercise = widget.exercisesService.getNextExercise();
                        isCorrectResponse = null;
                        enableCheck = false;
                        repeatCount++;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'DALJE',
                        style: TextStyle(
                          color: isCorrectResponse == true
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onError,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStaticStatementArea() {
    Widget statementArea = Text(
        '${exercise!.statement} '
        '(${exercise!.id}, difficulty: ${exercise!.difficulty})',
        style: const TextStyle(fontSize: 20.0));
    return statementArea;
  }

  Widget _buildStaticQuestionArea() {
    if (!(exercise is ExerciseMC || exercise is ExerciseSA)) {
      throw Exception(
          "Question area is only available for MC and SA exercises");
    }

    Widget questionArea;
    if ((exercise! as dynamic).question?.isEmpty == false) {
      questionArea = Text((exercise! as dynamic).question!,
          style: const TextStyle(fontSize: 20.0));
    } else {
      questionArea = const SizedBox.shrink();
    }
    return questionArea;
  }

  Widget _buildStaticCodeArea() {
    if (!(exercise is ExerciseMC ||
        exercise is ExerciseSA ||
        exercise is ExerciseSCW)) {
      throw Exception(
          "Code area is only available for MC, SA and SCW exercises");
    }
    Widget codeArea;
    if ((exercise! as dynamic).statementCode?.isNotEmpty) {
      codeArea = Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(10),
            dashPattern: const [9, 6],
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth,
                        minWidth: constraints.maxWidth,
                      ),
                      child: Text(
                        (exercise! as dynamic).statementCode!,
                        style: const TextStyle(
                          fontFamily: 'courier new',
                          fontSize: 20.0,
                        ),
                        softWrap: true,
                      ),
                    ),
                  ),
                );
              },
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
