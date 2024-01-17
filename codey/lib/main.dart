import 'package:codey/auth/authenticated_client.dart';
import 'package:codey/repositories/exercises_repository.dart';
import 'package:codey/repositories/lesson_groups_repository.dart';
import 'package:codey/repositories/lessons_repository.dart';
import 'package:codey/services/auth_service.dart';
import 'package:codey/widgets/lesson_groups_list.dart';
import 'package:codey/services/exercises_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codey/widgets/screens/login_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthenticatedClient>(
          create: (_) => AuthenticatedClient(),
        ),
        Provider<ExercisesRepository>(
          create: (_) => ExercisesRepository(),
        ),
        Provider<LessonGroupsRepository>(
          create: (_) => LessonGroupsRepository(),
        ),
        Provider<LessonsRepository>(
          create: (_) => LessonsRepository(),
        ),
        Provider<ExercisesService>(
          create: (context) =>
              ExercisesServiceV1(context.read<ExercisesRepository>()),
        ),
        Provider<AuthService>(
          create: (context) => AuthService(context.read<AuthenticatedClient>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
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
  bool loggedIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(30.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              loggedIn
                  ? LessonGroupsList(title: 'A')
                  : LoginScreen(onLogin: () => setState(() => loggedIn = true)),
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
