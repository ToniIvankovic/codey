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
  String email = '';
  String password = '';
  String? errorMessage;
  bool waitingResponse = false;

  @override
  Widget build(BuildContext context) {
    SessionService sessionService = context.read<SessionService>();

    TextField emailTextField = TextField(
      autofillHints: const [AutofillHints.username, AutofillHints.email],
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Korisničko ime',
      ),
      onChanged: (value) {
        setState(() {
          email = value;
          errorMessage = null;
        });
      },
    );

    TextField passwordTextField = TextField(
      autofillHints: const [AutofillHints.password],
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Lozinka',
      ),
      obscureText: true,
      onChanged: (value) {
        setState(() {
          password = value;
          errorMessage = null;
        });
      },
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: emailTextField,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: passwordTextField,
        ),
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
                setState(() {
                  waitingResponse = true;
                });
                sessionService
                    .login(username: email, password: password)
                    .then((value) {
                  widget.onLogin();
                  setState(() {
                    waitingResponse = false;
                  });
                }).onError((error, stackTrace) {
                  setState(() {
                    waitingResponse = false;
                    errorMessage = error.toString();
                  });
                });
              },
              child: const Text('Prijava'),
            ),
          ),
      ],
    );
  }
}
