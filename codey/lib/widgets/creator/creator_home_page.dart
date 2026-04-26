import 'package:codey/models/entities/course.dart';
import 'package:codey/services/courses_service.dart';
import 'package:codey/services/session_service.dart';
import 'package:codey/services/user_service.dart';
import 'package:codey/widgets/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'exercise/edit_exercises_screen.dart';
import 'lesson_group/edit_lesson_groups_screen.dart';
import 'lesson/edit_lessons_screen.dart';

class CreatorHomePage extends StatefulWidget {
  const CreatorHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<CreatorHomePage> createState() => _CreatorHomePageState();
}

class _CreatorHomePageState extends State<CreatorHomePage> {
  List<Course> _courses = [];
  int? _selectedCourseId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userService = context.read<UserService>();
    final coursesService = context.read<CoursesService>();
    final user = await userService.userStream.first;
    final courses = await coursesService.getAllCourses();
    if (!mounted) return;
    setState(() {
      _courses = courses;
      _selectedCourseId = user.course.id;
      _loading = false;
    });
  }

  Future<void> _onCourseChanged(int? courseId) async {
    if (courseId == null || courseId == _selectedCourseId) return;
    setState(() => _loading = true);
    try {
      await context.read<UserService>().switchCourse(courseId);
      setState(() {
        _selectedCourseId = courseId;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška pri promjeni tečaja: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const padd = EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 8.0);
    var lessonGroupsButton = Expanded(
      child: Padding(
        padding: padd,
        child: ElevatedButton(
          onPressed: _loading ? null : () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditLessonGroupsScreen(),
              ),
            );
          },
          child: const Text('Lesson groups'),
        ),
      ),
    );
    var lessonsButton = Expanded(
      child: Padding(
        padding: padd,
        child: ElevatedButton(
          onPressed: _loading ? null : () {
            final course = _courses.firstWhere((c) => c.id == _selectedCourseId);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditLessonsScreen(course: course),
              ),
            );
          },
          child: const Text('Lessons'),
        ),
      ),
    );
    var exercisesButton = Expanded(
      child: Padding(
        padding: padd,
        child: ElevatedButton(
          onPressed: _loading ? null : () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditExercisesScreen(),
              ),
            );
          },
          child: const Text('Exercises'),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Postavke',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You are logged in as a creator.',
            ),
            const SizedBox(height: 16),
            if (_loading)
              const SizedBox(
                height: 64,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_courses.isNotEmpty)
              Padding(
                padding: padd,
                child: DropdownButton<int>(
                  value: _selectedCourseId,
                  isExpanded: true,
                  items: _courses
                      .map((course) => DropdownMenuItem<int>(
                            value: course.id,
                            child: Text(course.name),
                          ))
                      .toList(),
                  onChanged: _onCourseChanged,
                ),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                lessonGroupsButton,
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                lessonsButton,
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                exercisesButton,
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () {
                  context.read<SessionService>().logout();
                },
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
