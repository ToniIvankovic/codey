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
  bool isProd = true;
  //isProd = false;
  String env = isProd ? ".env.prod" : ".env.dev";
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
  final colorScheme4 = const ColorScheme(
    surface: Color(0xffffffff),
    onSurface: Color(0xff1d1d1d),
    primary: Color(0xff389c9a),
    secondary: Color(0xfffedb71),
    inverseSurface: Color(0xfff8f8f8),
    onInverseSurface: Color(0xff1d1d1d),
    error: Color.fromARGB(255, 233, 76, 76),
    errorContainer: Color.fromARGB(255, 242, 194, 196),
    inversePrimary: Color(0xffcbf3f0),
    primaryContainer: Color(0xffcbf3f0),
    onPrimaryContainer: Color(0xff389c9a),
    onPrimary: Color(0xfff8f8f8),
    onSecondary: Color(0xff1d1d1d),
    onError: Color(0xfff8f8f8),
    onErrorContainer: Color.fromARGB(255, 209, 66, 66),
    brightness: Brightness.light,
  );
  final colorScheme4Dark = const ColorScheme(
    surface: Color.fromARGB(255, 40, 48, 47),
    onSurface: Color.fromARGB(255, 177, 211, 209),
    primary: Color(0xff389c9a),
    secondary: Color(0xfffedb71),
    error: Color.fromARGB(255, 189, 78, 82),
    errorContainer: Color.fromARGB(255, 139, 47, 50),
    onErrorContainer: Color.fromARGB(255, 255, 209, 210),
    inversePrimary: Color.fromARGB(255, 23, 60, 53),
    primaryContainer: Color.fromARGB(255, 41, 100, 95),
    onPrimaryContainer: Color(0xffcbf3f0),
    onPrimary: Color(0xfff8f8f8),
    onSecondary: Color(0xff1d1d1d),
    inverseSurface: Color.fromARGB(255, 58, 59, 59),
    onInverseSurface: Color.fromARGB(255, 177, 211, 209),
    onError: Color(0xfff8f8f8),
    brightness: Brightness.dark,
  );
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Codey',
      theme: ThemeData(
        colorScheme: colorScheme4,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: colorScheme4Dark,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
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
  bool loggedIn = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: context.read<AuthService>().token,
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
          return AuthScreen(
            onLogin: () => setState(() => loggedIn = true),
          );
        }
        onLogout() {
          context.read<SessionService>().logout();
          setState(() => loggedIn = false);
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
                        onPressed: () => onLogout(),
                        child: const Text("Odjava"),
                      )
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError || snapshot.data == null) {
              onLogout();
              return const Scaffold(
                body: Center(
                  child: Text('Greška: korisnik nije pronađen'),
                ),
              );
            } else {
              final user = snapshot.data!;

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
                  key: ValueKey(user),
                  onLogoutSuper: onLogout,
                  user: user,
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
