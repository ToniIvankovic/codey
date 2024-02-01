import 'package:codey/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLogin;
  const LoginScreen({Key? key, required this.onLogin}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String username = '';
  String password = '';
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
        if (errorMessage != null)
          Text(
            errorMessage!,
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () async {
              try {
                await context.read<AuthService>().login(username, password);
                widget.onLogin();
              } catch (e) {
                print('Error occurred: $e');
                setState(() {
                  errorMessage = e.toString().replaceFirst("Exception: ", "");
                });
              }
            },
            child: const Text('Login'),
          ),
        ),
      ],
    );
  }
}
