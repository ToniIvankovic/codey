import 'package:codey/services/admin_functions_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                  .registerCreator(email: email, password: password)
                  .then((value) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Creator created successfully'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $error'),
                    duration: const Duration(seconds: 2),
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
