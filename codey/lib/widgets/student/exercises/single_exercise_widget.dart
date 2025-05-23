import 'package:codey/models/entities/exercise.dart';
import 'package:codey/models/entities/exercise_LA.dart';
import 'package:codey/models/entities/exercise_MC.dart';
import 'package:codey/models/entities/exercise_SA.dart';
import 'package:codey/models/entities/exercise_SCW.dart';
import 'package:codey/services/exercises_service.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';

import 'exercise_LA_widget.dart';
import 'exercise_MC_widget.dart';
import 'exercise_SA_widget.dart';
import 'exercise_SCW_widget.dart';

class SingleExerciseWidget extends StatefulWidget {
  const SingleExerciseWidget({
    Key? key,
    required this.exercisesService,
    required this.onSessionFinished,
    this.onNextExercise,
  }) : super(key: key);

  final ExercisesService exercisesService;
  final VoidCallback onSessionFinished;
  final VoidCallback? onNextExercise;

  @override
  State<SingleExerciseWidget> createState() => _SingleExerciseWidgetState();
}

class _SingleExerciseWidgetState extends State<SingleExerciseWidget> {
  bool? isCorrectResponse;
  dynamic answer;
  bool enableCheck = false;
  bool waitingForResponse = false;
  Exercise? exercise;
  int repeatCount = 0;
  var childrenEnabledChanges = ValueNotifier<bool>(true);
  var childrenSignalCorrect = ValueNotifier<bool?>(null);
  final _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    exercise = widget.exercisesService.currentExercise;
  }

  @override
  Widget build(BuildContext context) {
    if (exercise == null) {
      widget.onSessionFinished();
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
          ],
        ),
      );
    }

    // single exercise, button
    return Container(
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width,
        maxWidth: MediaQuery.of(context).size.width,
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height - kToolbarHeight,
                  // maxWidth: MediaQuery.of(context).size.width,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 800,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: context
                                          .read<ExercisesService>()
                                          .sessionProgress,
                                      borderRadius: BorderRadius.circular(10),
                                      minHeight: 20,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            if (exercise?.repeated == true)
                              Row(
                                children: [
                                  Icon(
                                    Icons.refresh,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  const Text(
                                    'Pogrešno odgovoreno',
                                  ),
                                ],
                              ),
                            if (exercise is ExerciseMC)
                              ExerciseMCWidget(
                                key: ValueKey(exercise!.id + 100 * repeatCount),
                                changesEnabled: childrenEnabledChanges,
                                correctAnswerSignal: childrenSignalCorrect,
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
                              )
                            else if (exercise is ExerciseSA)
                              ExerciseSAWidget(
                                key: ValueKey(exercise!.id + 100 * repeatCount),
                                changesEnabled: childrenEnabledChanges,
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
                              )
                            else if (exercise is ExerciseLA)
                              ExerciseLAWidget(
                                key: ValueKey(exercise!.id + 100 * repeatCount),
                                changesEnabled: childrenEnabledChanges,
                                exercise: exercise! as ExerciseLA,
                                onAnswerSelected: (answer) {
                                  setState(() {
                                    this.answer = answer;
                                    enableCheck = answer.isNotEmpty;
                                  });
                                },
                                statementArea: _buildStaticStatementArea(),
                                // questionArea: _buildStaticQuestionArea(),
                              )
                            else if (exercise is ExerciseSCW)
                              ExerciseSCWWidget(
                                key: ValueKey(exercise!.id + 100 * repeatCount),
                                changesEnabled: childrenEnabledChanges,
                                exercise: exercise! as ExerciseSCW,
                                onAnswerSelected: (answer) {
                                  setState(() {
                                    this.answer = answer;
                                    enableCheck = answer.isNotEmpty &&
                                        answer.every(
                                            (element) => element.isNotEmpty);
                                  });
                                },
                                statementArea: _buildStaticStatementArea(),
                              ),
                            if (exercise!.specificTip != null)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20.0),
                                child: Text(
                                  "**HINT**\n${exercise!.specificTip!}",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (isCorrectResponse == null) _buildCheckButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isCorrectResponse != null) _buildNextButtonArea(),
        ],
      ),
    );
  }

  Widget _buildCheckButton() {
    Widget content = waitingForResponse
        ? const CircularProgressIndicator() //TODO: provjeri jel radi
        : const Text('PROVJERA');
    return Container(
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width,
        maxWidth: MediaQuery.of(context).size.width,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: null),
            onPressed: enableCheck
                ? () {
                    setState(() {
                      enableCheck = false;
                      childrenEnabledChanges.value = false;
                    });
                    widget.exercisesService.checkAnswer(exercise!, answer).then(
                      (value) {
                        setState(() {
                          isCorrectResponse = value;
                          childrenSignalCorrect.value = value;
                        });
                      },
                    );
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: content,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButtonArea() {
    var correctAnswer = widget.exercisesService.getCorrectAnswer(exercise!);
    if (exercise is ExerciseSCW) {
      var answerWithCode = (exercise as ExerciseSCW).statementCode;
      for (var answer in correctAnswer) {
        answerWithCode = answerWithCode.replaceFirst(
          "\\gap",
          answer,
        );
      }
      correctAnswer = answerWithCode;
    }
    var containerTextColor = TextStyle(
      color: isCorrectResponse == true
          ? Theme.of(context).colorScheme.onPrimaryContainer
          : Theme.of(context).colorScheme.onErrorContainer,
    );
    var buttonTextColor = TextStyle(
      color: isCorrectResponse == true
          ? Theme.of(context).colorScheme.onPrimary
          : Theme.of(context).colorScheme.onError,
    );
    return Positioned(
      bottom: 0,
      left: 0,
      child: Container(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
          maxWidth: MediaQuery.of(context).size.width,
        ),
        color: isCorrectResponse == true
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.95)
            : Theme.of(context).colorScheme.errorContainer.withOpacity(0.9),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                    child: Icon(
                      isCorrectResponse == true
                          ? Icons.check
                          : Icons.clear_outlined,
                      color: containerTextColor.color,
                    ),
                  ),
                  Text(
                    isCorrectResponse == true ? 'Točno!' : 'Netočno...',
                    style: containerTextColor.copyWith(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (isCorrectResponse != true)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    children: [
                      Text(
                        'Točan odgovor:',
                        style: containerTextColor.copyWith(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        correctAnswer,
                        style: containerTextColor.copyWith(
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),
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
                        if (widget.onNextExercise != null) {
                          widget.onNextExercise!();
                        }
                        childrenEnabledChanges.value = true;
                        childrenSignalCorrect.value = null;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'DALJE',
                        style: TextStyle(
                          color: buttonTextColor.color,
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
    if (exercise!.statement == null) {
      return const SizedBox.shrink();
    }
    return Text('${exercise!.statement} ',
        style: const TextStyle(fontSize: 20.0));
  }

  Widget _buildStaticQuestionArea() {
    if (!(exercise is ExerciseMC || exercise is ExerciseSA)) {
      throw Exception(
          "Question area is only available for MC and SA exercises");
    }

    if ((exercise! as dynamic).question?.isEmpty) {
      return const SizedBox.shrink();
    }
    return Text((exercise! as dynamic).question!,
        style: const TextStyle(fontSize: 20.0));
  }

  Widget _buildStaticCodeArea() {
    if (!(exercise is ExerciseMC ||
        exercise is ExerciseSA ||
        exercise is ExerciseSCW)) {
      throw Exception(
          "Code area is only available for MC, SA and SCW exercises");
    }

    if ((exercise! as dynamic).statementCode?.isEmpty) {
      return const SizedBox.shrink();
    }
    String code = (exercise! as dynamic).statementCode!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: const Radius.circular(10),
          dashPattern: const [9, 6],
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth - 20,
                      ),
                      child: Text(
                        code,
                        style: const TextStyle(
                          fontFamily: 'courier new',
                          fontSize: 20.0,
                        ),
                        // softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
