import 'dart:math';

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
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
              maxWidth: min(MediaQuery.of(context).size.width, 800),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(showLogin ? 'Prijava' : 'Registracija',
                        style: Theme.of(context).textTheme.displaySmall),
                  ),
                  if (showLogin)
                    LoginWidget(
                      onLogin: widget.onLogin,
                    )
                  else
                    RegistrationWidget(
                      onRegistration: () {
                        setState(() {
                          showLogin = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Uspješna registracija! Sada se možete prijaviti.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        showLogin = !showLogin;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            showLogin
                                ? "Nemaš račun? Registriraj se"
                                : "Već imaš račun? Prijavi se",
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
