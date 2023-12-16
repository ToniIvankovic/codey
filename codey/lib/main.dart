import 'package:codey/lesson_groups_list.dart';
import 'package:codey/repositories/exercises_repository.dart';
import 'package:codey/repositories/lesson_groups_repository.dart';
import 'package:codey/repositories/lessons_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/data_service.dart';

void main() {
    runApp(Provider<DataService>(
      create: (_) => DataServiceV1(),
      child: Provider<ExercisesRepository>(
        create: (_) => ExercisesRepository(),
        child: Provider<LessonGroupsRepository>(
          create: (_) => LessonGroupsRepository(),
          child: Provider<LessonsRepository>(
            create: (_) => LessonsRepository(),
            child: const MyApp())))));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 37, 9, 198)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}


class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LessonGroupsList(title: 'A', lessonGroupsRepository: Provider.of<LessonGroupsRepository>(context)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => print("back"),
        tooltip: 'Back',
        child: const Icon(Icons.arrow_back),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
