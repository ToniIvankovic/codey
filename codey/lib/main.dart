import 'package:codey/auth/authenticated_client.dart';
import 'package:codey/models/entities/app_user.dart';
import 'package:codey/repositories/exercises_repository.dart';
import 'package:codey/repositories/lesson_groups_repository.dart';
import 'package:codey/repositories/lessons_repository.dart';
import 'package:codey/services/admin_functions_service.dart';
import 'package:codey/services/auth_service.dart';
import 'package:codey/services/lesson_groups_service.dart';
import 'package:codey/services/lessons_service.dart';
import 'package:codey/services/session_service.dart';
import 'package:codey/services/user_interaction_service.dart';
import 'package:codey/services/user_service.dart';
import 'package:codey/widgets/admin/admin_home_page.dart';
import 'package:codey/widgets/student/student_home_screen.dart';
import 'package:codey/services/exercises_service.dart';
import 'package:codey/widgets/auth/auth_screen.dart';
import 'package:codey/widgets/teacher/teacher_home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;

import 'widgets/creator/creator_home_page.dart';

Future main() async {
  // String mode = 'prod';
  String mode = 'dev';
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
        Provider<AdminFunctionsService>(
          create: (context) =>
              AdminFunctionsServiceImpl(context.read<AuthenticatedClient>()),
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
          create: (context) => LessonGroupsServiceV1(
              context.read<LessonGroupsRepository>(),
              context.read<AuthenticatedClient>()),
        ),
        Provider<LessonsRepository>(
          create: (context) => LessonsRepository1(
              context.read<AuthenticatedClient>(),
              context.read<ExercisesRepository>()),
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
        Provider<UserInteractionService>(
          create: (context) => UserInteractionServiceImpl(
            context.read<AuthenticatedClient>(),
          ),
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
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null) {
          return AuthScreen(
            onLogin: () => setState(() => loggedIn = true),
          );
        }

        return StreamBuilder<AppUser>(
          stream: context.read<UserService>().userStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (snapshot.hasError || snapshot.data == null) {
              return Text('Error: ${snapshot.error}');
            } else {
              final user = snapshot.data!;
              onLogout() {
                context.read<SessionService>().logout();
                setState(() => loggedIn = false);
              }

              if (user.roles.contains("ADMIN")) {
                return AdminHomePage(
                  onLogoutSuper: onLogout,
                );
              }
              if (user.roles.contains("CREATOR")) {
                return CreatorHomePage(
                  title: widget.title,
                  onLogoutSuper: onLogout,
                );
              }
              if (user.roles.contains("TEACHER")) {
                return TeacherHomePage(
                  onLogoutSuper: onLogout,
                );
              }
              if (user.roles.contains("STUDENT")) {
                return StudentHomeScreen(
                  onLogoutSuper: onLogout,
                );
              }
              return const Scaffold(
                  body: Center(child: Text('Error: User has no roles')));
            }
          },
        );
      },
    );
  }
}
