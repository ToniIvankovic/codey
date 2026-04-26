import 'dart:async';

import 'package:codey/auth/authenticated_client.dart';
import 'package:http/http.dart' as http;
import 'package:codey/models/entities/app_user.dart';
import 'package:codey/repositories/courses_repository.dart';
import 'package:codey/repositories/exercises_repository.dart';
import 'package:codey/repositories/lesson_groups_repository.dart';
import 'package:codey/repositories/lessons_repository.dart';
import 'package:codey/services/admin_functions_service.dart';
import 'package:codey/services/auth_service.dart';
import 'package:codey/services/courses_service.dart';
import 'package:codey/services/lesson_groups_service.dart';
import 'package:codey/services/lessons_service.dart';
import 'package:codey/services/session_service.dart';
import 'package:codey/services/theme_service.dart';
import 'package:codey/services/user_interaction_service.dart';
import 'package:codey/services/user_service.dart';
import 'package:codey/widgets/admin/admin_home_page.dart';
import 'package:codey/widgets/student/student_home_screen.dart';
import 'package:codey/services/exercises_service.dart';
import 'package:codey/widgets/auth/auth_screen.dart';
import 'package:codey/widgets/teacher/teacher_home_page.dart';
import 'package:codey/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;

import 'widgets/creator/creator_home_page.dart';

Future main() async {
  const env = String.fromEnvironment('ENV', defaultValue: 'prod');
  await dotenv.dotenv.load(fileName: '.env.$env');
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (context) => AuthService1(),
        ),
        Provider<AuthenticatedClient>(
          create: (context) => AuthenticatedClient(context.read<AuthService>()),
        ),
        Provider<UserService>(
          create: (context) => UserService1(
            context.read<AuthService>(),
            context.read<AuthenticatedClient>(),
          ),
        ),
        Provider<SessionService>(
          create: (context) => SessionService1(
            context.read<AuthService>(),
            context.read<UserService>(),
          ),
        ),
        Provider<AdminFunctionsService>(
          create: (context) =>
              AdminFunctionsServiceImpl(context.read<AuthenticatedClient>()),
        ),
        Provider<ExercisesRepository>(
          create: (context) => ExercisesRepository1(
            context.read<AuthenticatedClient>(),
          ),
        ),
        Provider<LessonGroupsRepository>(
          create: (context) => LessonGroupsRepository1(
            context.read<AuthenticatedClient>(),
            context.read<UserService>(),
            context.read<SessionService>(),
          ),
        ),
        Provider<LessonGroupsService>(
          create: (context) => LessonGroupsServiceV1(
              context.read<LessonGroupsRepository>()),
        ),
        Provider<LessonsRepository>(
          create: (context) => LessonsRepository1(
            context.read<AuthenticatedClient>(),
            context.read<UserService>(),
            context.read<SessionService>(),
          ),
        ),
        Provider<LessonsService>(
          create: (context) =>
              LessonsServiceV1(context.read<LessonsRepository>()),
        ),
        Provider<ExercisesService>(
          create: (context) => ExercisesServiceV1(
            context.read<ExercisesRepository>(),
            context.read<AuthenticatedClient>(),
            context.read<UserService>(),
          ),
        ),
        Provider<UserInteractionService>(
          create: (context) => UserInteractionServiceImpl(
            context.read<AuthenticatedClient>(),
          ),
        ),
        Provider<CoursesRepository>(
          create: (context) => CoursesRepository1(http.Client()),
        ),
        Provider<CoursesService>(
          create: (context) =>
              CoursesServiceV1(context.read<CoursesRepository>()),
        ),
        ChangeNotifierProvider<ThemeService>(
          create: (context) => ThemeServiceImpl(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  StreamSubscription<void>? _loginSub;
  StreamSubscription<void>? _logoutSub;

  @override
  void initState() {
    super.initState();
    final authService = context.read<AuthService>();
    final sessionService = context.read<SessionService>();
    authService.token.then((token) {
      if (mounted) setState(() => _isLoggedIn = token != null);
    });
    _loginSub = sessionService.loginStream.listen((_) {
      if (mounted) setState(() => _isLoggedIn = true);
    });
    _logoutSub = sessionService.logoutStream.listen((_) {
      if (mounted) setState(() => _isLoggedIn = false);
    });
  }

  @override
  void dispose() {
    _loginSub?.cancel();
    _logoutSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    return MaterialApp(
      title: 'Codey',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _isLoggedIn ? themeService.mode : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Codey'),
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
  StreamSubscription<void>? _loginSub;
  StreamSubscription<void>? _logoutSub;
  late Future<String?> _tokenFuture;

  void _refreshToken() {
    if (mounted) {
      setState(() {
        _tokenFuture = context.read<AuthService>().token;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tokenFuture = context.read<AuthService>().token;
    final sessionService = context.read<SessionService>();
    _loginSub = sessionService.loginStream.listen((_) => _refreshToken());
    _logoutSub = sessionService.logoutStream.listen((_) => _refreshToken());
  }

  @override
  void dispose() {
    _loginSub?.cancel();
    _logoutSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _tokenFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                children: [
                  Text("Učitavanje... (1)"),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          );
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data == null) {
          if (snapshot.hasError) {
            debugPrint('AuthService.token error: ${snapshot.error}');
            debugPrint('${snapshot.stackTrace}');
          }
          return const AuthScreen();
        }

        return StreamBuilder<AppUser>(
          stream: context.read<UserService>().userStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Učitavanje podataka o korisniku..."),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<SessionService>().logout(),
                        child: const Text("Odjava"),
                      )
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError || snapshot.data == null) {
              if (snapshot.hasError) {
                debugPrint('UserService.userStream error: ${snapshot.error}');
                debugPrint('${snapshot.stackTrace}');
              }
              context.read<SessionService>().logout();
              return const Scaffold(
                body: Center(
                  child: Text('Greška: korisnik nije pronađen'),
                ),
              );
            } else {
              final user = snapshot.data!;

              if (user.roles.contains("ADMIN")) {
                return const AdminHomePage();
              }
              if (user.roles.contains("CREATOR")) {
                return CreatorHomePage(
                  title: widget.title,
                );
              }
              if (user.roles.contains("TEACHER")) {
                return const TeacherHomePage();
              }
              if (user.roles.contains("STUDENT")) {
                return StudentHomeScreen(
                  key: ValueKey(user),
                  user: user,
                  course: user.course,
                );
              }
              return const Scaffold(
                  body: Center(child: Text('Greška: Korisnik nema uloga')));
            }
          },
        );
      },
    );
  }
}
