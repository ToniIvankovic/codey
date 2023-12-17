import 'dart:math';

import 'package:codey/models/exercise.dart';
import 'package:codey/models/exercise_LA.dart';
import 'package:codey/models/exercise_MC.dart';
import 'package:codey/models/exercise_SA.dart';
import 'package:codey/models/lesson.dart';
import 'package:codey/repositories/exercises_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExercisesScreen extends StatelessWidget {
  final Lesson lesson;

  ExercisesScreen({required this.lesson});

  @override
  Widget build(BuildContext context) {
    var exercisesRepository = Provider.of<ExercisesRepository>(context);
    Future<List<Exercise>> exercisesFuture =
        exercisesRepository.getExercisesForLesson(lesson.id.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text('Lesson: ${lesson.name}'),
      ),
      body: Center(
        child: FutureBuilder<List<Exercise>>(
          future: exercisesFuture,
          builder:
              (BuildContext context, AsyncSnapshot<List<Exercise>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(
                strokeWidth: 5,
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.data == null) {
              return const Text('No data');
            } else {
              var exercises = snapshot.data!;
              return ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (BuildContext context, int index) {
                  Exercise exercise = exercises[index];
                  return ListTile(
                    title: Text(
                        '${exercise.statement} (${exercise.id}, difficulty: ${exercise.difficulty})'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (exercise.statementCode?.isEmpty == false &&
                            exercise.statementCode != null)
                          Text(exercise.statementCode!),
                        if (exercise.question?.isEmpty == false &&
                            exercise.question != null)
                          Text(exercise.question!),
                        if (exercise is ExerciseMC)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10.0,0,0,0),
                            child: Text(exercise.answerOptions.entries
                                .map((entry) => '${entry.key}: ${entry.value}')
                                .join('\n')),
                          ),
                        if (exercise is ExerciseMC)
                          Text(exercise.correctAnswer, style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (exercise is ExerciseSA)
                          const TextField(
                            decoration: InputDecoration(
                              labelText: 'Answer',
                            ),
                            maxLines: null,
                          ),
                        if (exercise is ExerciseLA)
                          const TextField(
                            decoration: InputDecoration(
                              labelText: 'Answer',
                            ),
                            maxLines: null,
                          ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
