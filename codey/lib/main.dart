import 'package:codey/auth/authenticated_client.dart';
import 'package:codey/repositories/exercises_repository.dart';
import 'package:codey/repositories/lesson_groups_repository.dart';
import 'package:codey/repositories/lessons_repository.dart';
import 'package:codey/services/auth_service.dart';
import 'package:codey/services/lesson_groups_service.dart';
import 'package:codey/services/lessons_service.dart';
import 'package:codey/services/session_service.dart';
import 'package:codey/services/user_service.dart';
import 'package:codey/widgets/lesson_groups/lesson_groups_screen.dart';
import 'package:codey/services/exercises_service.dart';
import 'package:codey/widgets/auth/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;

Future main() async {
  String mode = 'prod';
  // String mode = 'dev';
  String env = '$mode.env';
  await dotenv.dotenv.load(fileName: env);
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (context) => AuthService1(),
        ),
        Provider<AuthenticatedClient>(
          create: (context) => AuthenticatedClient(context.read<AuthService>()),
        ),
        Provider<ExercisesRepository>(
          create: (context) =>
              ExercisesRepository1(context.read<AuthenticatedClient>()),
        ),
        Provider<LessonGroupsRepository>(
          create: (context) =>
              LessonGroupsRepository1(context.read<AuthenticatedClient>()),
        ),
        Provider<LessonGroupsService>(
          create: (context) =>
              LessonGroupsServiceV1(context.read<LessonGroupsRepository>()),
        ),
        Provider<LessonsRepository>(
          create: (context) =>
              LessonsRepository1(context.read<AuthenticatedClient>()),
        ),
        Provider<LessonsService>(
          create: (context) =>
              LessonsServiceV1(context.read<LessonsRepository>()),
        ),
        Provider<UserService>(
            create: (context) => UserService1(context.read<AuthService>(),
                context.read<AuthenticatedClient>())),
        Provider<ExercisesService>(
          create: (context) => ExercisesServiceV1(
            context.read<ExercisesRepository>(),
            context.read<AuthenticatedClient>(),
            context.read<UserService>(),
          ),
        ),
        Provider<SessionService>(
          create: (context) => SessionService1(
              context.read<AuthService>(), context.read<UserService>()),
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
      title: 'Codey',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 37, 9, 198)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Codey - Python Course'),
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
    return FutureBuilder<String?>(
      future: context.read<AuthService>().token,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null) {
          return AuthScreen(
            onLogin: () => setState(() => loggedIn = true),
          );
        }

        return LessonGroupsScreen(
            onLogoutSuper: () => setState(() => loggedIn = false));
      },
    );
  }
}
