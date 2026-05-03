import 'package:codey/services/session_service.dart';
import 'package:codey/widgets/settings/settings_screen.dart';
import 'package:codey/widgets/student/gamification_widgets/leaderboard_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_classes_screen.dart';

class TeacherHomePage extends StatelessWidget {
  const TeacherHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Naslovnica za Učitelje'),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                constraints: const BoxConstraints(minWidth: 400, minHeight: 70),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ViewClassesScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Pregled razreda",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: LeaderboardWidget(
                  requestedByTeacher: true,
                  showUsernames: true,
                  persistCourseChange: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<SessionService>().logout();
                    },
                    child: const Text('Odjava'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
