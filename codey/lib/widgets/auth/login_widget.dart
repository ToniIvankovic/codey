import 'package:codey/services/session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({Key? key}) : super(key: key);

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

    void submit() {
      if (waitingResponse) return;
      setState(() {
        waitingResponse = true;
      });
      TextInput.finishAutofillContext(shouldSave: true);
      sessionService
          .login(username: email, password: password)
          .then((value) {
        if (mounted) setState(() { waitingResponse = false; });
      }).onError((error, stackTrace) {
        setState(() {
          waitingResponse = false;
          errorMessage = error.toString();
        });
      });
    }

    TextField emailTextField = TextField(
      autofillHints: const [AutofillHints.username, AutofillHints.email],
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Korisničko ime',
      ),
      textInputAction: TextInputAction.next,
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
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => submit(),
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
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
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
              onPressed: submit,
              child: const Padding(
                padding: EdgeInsets.all(5),
                child: Text('Prijava'),
              ),
            ),
          ),
      ],
    );
  }
}
