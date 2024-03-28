import 'package:flutter/material.dart';

abstract class ExerciseCreationComponent extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final void Function(dynamic) onChange;
  const ExerciseCreationComponent({
    super.key,
    required this.formKey,
    required this.onChange,
  });
}