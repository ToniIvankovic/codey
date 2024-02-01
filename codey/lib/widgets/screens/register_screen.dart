import 'package:codey/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistrationScreen extends StatefulWidget {
  final VoidCallback onRegistration;
  const RegistrationScreen({Key? key, required this.onRegistration}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String username = '';
  String password = '';
  String confirmPassword = '';
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Username',
          ),
          onChanged: (value) {
            setState(() {
              username = value;
              errorMessage = null;
            });
          },
        ),
        TextField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Password',
          ),
          onChanged: (value) {
            setState(() {
              password = value;
              errorMessage = null;
            });
          },
        ),
        TextField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Confirm Password',
          ),
          onChanged: (value) {
            setState(() {
              confirmPassword = value;
              errorMessage = null;
            });
          },
        ),
        if(errorMessage != null)
          Text(
            errorMessage!,
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
        ElevatedButton(
          onPressed: () async {
            if (password != confirmPassword) {
              setState(() {
                errorMessage = 'Passwords do not match';
              });
              return;
            }
            try {
              await context.read<AuthService>().register(username, password);
              widget.onRegistration();
            } catch (e) {
              print('Error occurred: $e');
              setState(() {
                errorMessage = e.toString();
              });
            }
          },
          child: const Text('Register'),
        ),
      ],
    );
  }
}