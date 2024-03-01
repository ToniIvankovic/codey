import 'package:codey/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistrationWidget extends StatefulWidget {
  final VoidCallback onRegistration;
  const RegistrationWidget({Key? key, required this.onRegistration})
      : super(key: key);

  @override
  State<RegistrationWidget> createState() => _RegistrationWidgetState();
}

class _RegistrationWidgetState extends State<RegistrationWidget> {
  String username = '';
  String password = '';
  String confirmPassword = '';
  String? errorMessage;
  bool waitingResponse = false;

  @override
  Widget build(BuildContext context) {
    final usernameField = TextField(
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
    );

    final passwordField = TextField(
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
    );

    final confirmPasswordField = TextField(
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
    );

    return Column(
      children: [
        usernameField,
        passwordField,
        confirmPasswordField,
        if (errorMessage != null)
          Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
        if (waitingResponse)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          )
        else
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                if (password != confirmPassword) {
                  setState(() {
                    errorMessage = 'Passwords do not match';
                  });
                  return;
                }
                try {
                  setState(() {
                    errorMessage = null;
                    waitingResponse = true;
                  });
                  await context
                      .read<AuthService>()
                      .register(username, password);
                  setState(() {
                    waitingResponse = false;
                  });
                  widget.onRegistration();
                } catch (e) {
                  setState(() {
                    waitingResponse = false;
                    errorMessage = e.toString();
                  });
                }
              },
              child: const Text('Register'),
            ),
          ),
      ],
    );
  }
}
