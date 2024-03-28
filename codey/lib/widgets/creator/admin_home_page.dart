import 'package:codey/services/admin_functions_service.dart';
import 'package:codey/services/session_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminHomePage extends StatelessWidget {
  final void Function() onLogoutSuper;

  const AdminHomePage({
    Key? key,
    required this.onLogoutSuper,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateCreatorScreen(),
                    ),
                  );
                },
                child: const Text("Create Creator"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  context.read<SessionService>().logout();
                  onLogoutSuper();
                },
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateCreatorScreen extends StatefulWidget {
  const CreateCreatorScreen({Key? key}) : super(key: key);

  @override
  State<CreateCreatorScreen> createState() => _CreateCreatorScreenState();
}

class _CreateCreatorScreenState extends State<CreateCreatorScreen> {
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Creator'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Email'),
            onChanged: (value) {
              setState(() {
                email = value;
              });
            },
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Password'),
            onChanged: (value) {
              setState(() {
                password = value;
              });
            },
          ),
          ElevatedButton(
            onPressed: () {
              context
                  .read<AdminFunctionsService>()
                  .registerCreator(email, password)
                  .then((value) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Creator created successfully'),
                  ),
                );
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $error'),
                  ),
                );
              });
            },
            child: const Text('Create Creator'),
          ),
        ],
      ),
    );
  }
}
