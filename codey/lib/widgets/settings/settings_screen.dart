import 'dart:async';

import 'package:codey/models/entities/app_user.dart';
import 'package:codey/services/theme_service.dart';
import 'package:codey/services/user_service.dart';
import 'package:codey/widgets/student/profile_data/change_password_screen.dart';
import 'package:codey/widgets/student/profile_data/change_user_data_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AppUser? _user;
  StreamSubscription? _userSub;

  @override
  void initState() {
    super.initState();
    final userService = context.read<UserService>();
    _userSub = userService.userStream.listen((user) {
      if (mounted) setState(() => _user = user);
    });
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Postavke'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        titleTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary, fontSize: 18),
        actionsIconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 100,
          ),
          child: Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _SectionTitle('Tema'),
                    const SizedBox(height: 16),
                    const _ThemeSelector(),
                    const SizedBox(height: 50),
                    const _SectionTitle('Moji podatci'),
                    const SizedBox(height: 30),
                    if (user == null)
                      const Center(child: CircularProgressIndicator())
                    else
                      _UserDataSection(user: user),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 24),
      textAlign: TextAlign.center,
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    return Center(
      child: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(
            value: ThemeMode.light,
            label: Text('Svijetla'),
            icon: Icon(Icons.light_mode),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            label: Text('Tamna'),
            icon: Icon(Icons.dark_mode),
          ),
          ButtonSegment(
            value: ThemeMode.system,
            label: Text('Sustav'),
            icon: Icon(Icons.settings_suggest),
          ),
        ],
        selected: {themeService.mode},
        onSelectionChanged: (selection) {
          themeService.setMode(selection.first);
        },
      ),
    );
  }
}

class _UserDataSection extends StatelessWidget {
  final AppUser user;
  const _UserDataSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _FieldLabel('Korisničko ime:'),
        _FieldValue(user.email),
        const SizedBox(height: 30),
        const _FieldLabel('Ime:'),
        _FieldValue(user.firstName ?? ''),
        const SizedBox(height: 30),
        const _FieldLabel('Prezime:'),
        _FieldValue(user.lastName ?? ''),
        const SizedBox(height: 30),
        if (user.dateOfBirth != null) ...[
          const _FieldLabel('Datum rođenja:'),
          _FieldValue(
              "${user.dateOfBirth!.day}.${user.dateOfBirth!.month}.${user.dateOfBirth!.year}."),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChangeUserDataScreen(
                    firstName: user.firstName,
                    lastName: user.lastName,
                    dateOfBirth: user.dateOfBirth,
                  ),
                ),
              );
            },
            child: const Text('Promijeni podatke'),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChangePasswordScreen(),
              ),
            );
          },
          child: const Text('Promijeni lozinku'),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _FieldValue extends StatelessWidget {
  final String text;
  const _FieldValue(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
