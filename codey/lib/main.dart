import 'package:codey/repositories/exercises_repository.dart';
import 'package:codey/repositories/lesson_groups_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/data_service.dart';

void main() {
  runApp(Provider<DataService>(
      create: (_) => DataServiceV1(),
      child: Provider<ExercisesRepository>(
          create: (_) => ExercisesRepository(), child: Provider<LessonGroupsRepository>(
          create: (_) => LessonGroupsRepository(), child: const MyApp()))));
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lgRepo = Provider.of<LessonGroupsRepository>(context);
    return Scaffold(
      backgroundColor:
          ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 0, 0, 0))
              .inverseSurface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => lgRepo.lessonGroups.then((value) => print(value)),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
