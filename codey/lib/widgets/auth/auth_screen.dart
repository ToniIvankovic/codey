import 'package:codey/widgets/auth/login_widget.dart';
import 'package:codey/widgets/auth/registration_widget.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onLogin;
  const AuthScreen({Key? key, required this.onLogin}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool showLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(showLogin ? 'Login' : 'Register',
                  style: Theme.of(context).textTheme.displaySmall),
            ),
            if (showLogin)
              LoginWidget(
                onLogin: widget.onLogin,
              )
            else
              RegistrationWidget(
                onRegistration: () => setState(() {
                  showLogin = true;
                }),
              ),
            TextButton(
              onPressed: () {
                setState(() {
                  showLogin = !showLogin;
                });
              },
              child: Text(showLogin
                  ? "Don't have an account? Register"
                  : 'Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
