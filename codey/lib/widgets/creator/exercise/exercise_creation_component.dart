
import 'package:codey/models/entities/exercise.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
abstract class ExerciseCreationComponent extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  Exercise Function({
    int? difficulty,
    String? statement,
    String? statementOutput,
    String? specificTip,
  })? createExercise;

  ExerciseCreationComponent({
    super.key,
    required this.formKey,
  });
}