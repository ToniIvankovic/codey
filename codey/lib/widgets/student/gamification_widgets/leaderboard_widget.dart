import 'dart:async';

import 'package:codey/models/entities/course.dart';
import 'package:codey/models/entities/leaderboard.dart';
import 'package:codey/services/courses_service.dart';
import 'package:codey/services/user_interaction_service.dart';
import 'package:codey/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LeaderboardWidget extends StatefulWidget {
  final bool requestedByTeacher;
  final int? classId;
  final bool showUsernames;
  const LeaderboardWidget({
    super.key,
    this.requestedByTeacher = false,
    this.classId,
    this.showUsernames = false,
  });

  @override
  State<LeaderboardWidget> createState() => _LeaderboardWidgetState();
}

class _LeaderboardWidgetState extends State<LeaderboardWidget> {
  Leaderboard? leaderboard;
  bool leaderboardLoading = false;
  String? _currentUserEmail;
  StreamSubscription? _userSub;
  List<Course> _courses = [];
  Course? _selectedCourse;

  @override
  void initState() {
    super.initState();
    leaderboardLoading = true;
    _userSub = context.read<UserService>().userStream.listen((user) {
      if (mounted) setState(() => _currentUserEmail = user.email);
    });
    if (widget.requestedByTeacher) {
      context.read<CoursesService>().getAllCourses().then((courses) {
        if (!mounted || courses.isEmpty) return;
        setState(() {
          _courses = courses;
          _selectedCourse = courses.first;
        });
        _loadLeaderboard();
      });
    } else {
      _loadLeaderboard();
    }
  }

  void _loadLeaderboard() {
    fetchLeaderboard().then((value) {
      if (!mounted) return;
      setState(() {
        leaderboard = value;
        leaderboardLoading = false;
      });
    }).catchError((_) {
      if (!mounted) return;
      setState(() {
        leaderboard = null;
        leaderboardLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  Future<Leaderboard> fetchLeaderboard() async {
    if (widget.requestedByTeacher) {
      return context
          .read<UserInteractionService>()
          .getLeaderboardClass(widget.classId!, _selectedCourse!.id);
    }
    return context.read<UserInteractionService>().getLeaderboardStudent();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondary,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10.0),
              child: Text(
                "Ljestvica poretka",
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
            if (widget.requestedByTeacher && _courses.isNotEmpty)
              DropdownButton<Course>(
                value: _selectedCourse,
                items: _courses
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                    .toList(),
                onChanged: (course) {
                  if (course == null || course == _selectedCourse) return;
                  setState(() {
                    _selectedCourse = course;
                    leaderboardLoading = true;
                    leaderboard = null;
                  });
                  _loadLeaderboard();
                },
              ),
            if (leaderboardLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                  ],
                ),
              )
            else if (!leaderboardLoading && leaderboard == null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Nema ljestvice poretka",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              )
            else
              for (var i = 0; i < leaderboard!.students.length; i++) ...[
                _generateLeaderboardRow(i),
                const SizedBox(height: 5.0),
              ]
          ],
        ),
      ),
    );
  }

  Widget _generateLeaderboardRow(int i) {
    final student = leaderboard!.students[i];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Builder(builder: (context) {
                final isSelf = _currentUserEmail == student.email;
                final nameStyle = TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontWeight: isSelf ? FontWeight.bold : FontWeight.normal,
                );
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${i + 1}. ", style: nameStyle),
                    Expanded(
                      child: Text(
                        "${student.firstName} ${student.lastName}:",
                        overflow: TextOverflow.clip,
                        style: nameStyle,
                      ),
                    ),
                  ],
                );
              }),
            ),
            if (student.streak > 0) ...[
              Text(
                "${student.streak}",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: Icon(Icons.whatshot, color: Colors.red, size: 20.0),
              ),
            ],
            Text(
              "${student.totalXp} XP",
              overflow: TextOverflow.visible,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ],
        ),
        if (widget.showUsernames)
          Row(
            children: [
              Text(
                "(${student.email})",
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSecondary
                      .withOpacity(0.6),
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
