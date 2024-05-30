import 'package:codey/models/entities/app_user.dart';
import 'package:flutter/material.dart';

class StudentProfileScreen extends StatelessWidget {
  final AppUser user;
  const StudentProfileScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        titleTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary, fontSize: 18),
        actionsIconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 60.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Ime: ${user.firstName}", style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
