import 'package:codey/services/session_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginWidget extends StatefulWidget {
  final VoidCallback onLogin;
  const LoginWidget({Key? key, required this.onLogin}) : super(key: key);

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  String username = '';
  String password = '';
  String? errorMessage;
  bool waitingResponse = false;

  @override
  Widget build(BuildContext context) {
    SessionService sessionService = context.read<SessionService>();

    TextField usernameTextField = TextField(
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

    TextField passwordTextField = TextField(
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

    return Column(
      children: [
        usernameTextField,
        passwordTextField,
        if (errorMessage != null)
          Text(
            errorMessage!,
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
                try {
                  setState(() {
                    waitingResponse = true;
                  });
                  await sessionService.login(username, password);
                  widget.onLogin();
                  setState(() {
                    waitingResponse = false;
                  });
                } catch (e) {
                  setState(() {
                    waitingResponse = false;
                    errorMessage = e.toString();
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
