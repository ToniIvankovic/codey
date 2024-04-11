import 'package:codey/services/auth_service.dart';
import 'package:codey/services/user_interaction_service.dart';
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
  var formKey = GlobalKey<FormState>();
  String username = '';
  String password = '';
  String confirmPassword = '';
  String? errorMessage;
  bool waitingResponse = false;

  String? school;
  final List<String> schools = [];

  @override
  void initState() {
    super.initState();
    context.read<UserInteractionService>().getAllSchools().then(
      (value) {
        setState(() {
          schools.addAll(value);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final usernameField = TextFormField(
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
      validator: (value) =>
          (value ?? "").isEmpty ? 'Please enter a username' : null,
    );

    final passwordField = TextFormField(
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
      validator: (value) =>
          (value ?? "").isEmpty ? 'Please enter a password' : null,
    );

    final confirmPasswordField = TextFormField(
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please repeat password';
          }
          if (value != password) {
            return 'Passwords do not match';
          }
          return null;
        });

    final schoolDropdown = Row(
      children: [
        Expanded(
          child: FormField<String>(
            builder: (FormFieldState<String> state) {
              return DropdownButtonFormField<String>(
                value: school,
                items: schools
                    .map((school) => DropdownMenuItem(
                          value: school,
                          child: Text(school),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    school = value!;
                  });
                },
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'School',
                  errorText: state.errorText,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a school';
                  }
                  return null;
                },
              );
            },
          ),
        ),
      ],
    );

    return Form(
      key: formKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: usernameField,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: passwordField,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: confirmPasswordField,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: schoolDropdown,
          ),
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
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  formKey.currentState!.save();
                  try {
                    setState(() {
                      errorMessage = null;
                      waitingResponse = true;
                    });
                    await context
                        .read<AuthService>()
                        .registerUser(username, password, school!);
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
      ),
    );
  }
}
