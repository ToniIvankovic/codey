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
  String firstName = '';
  String lastName = '';
  int? day;
  int? month;
  int? year;
  String email = '';
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
    final firstNameField = TextFormField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'First Name *',
      ),
      onChanged: (value) {
        setState(() {
          firstName = value;
          errorMessage = null;
        });
      },
      validator: (value) =>
          (value ?? "").isEmpty ? 'Please enter your first name' : null,
    );
    final lastNameField = TextFormField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Last Name *',
      ),
      onChanged: (value) {
        setState(() {
          lastName = value;
          errorMessage = null;
        });
      },
      validator: (value) =>
          (value ?? "").isEmpty ? 'Please enter your last name' : null,
    );

    DateTime? dateOfBirth;
    if (year != null && month != null && day != null) {
      dateOfBirth = DateTime(year!, month!, day!);
    }
    final dateOfBirthRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 8.0, 0),
          child: SizedBox(
            width: 60,
            child: TextFormField(
              maxLength: 2,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Day',
                counterText: "",
              ),
              onChanged: (value) {
                setState(() {
                  day = int.tryParse(value);
                  errorMessage = null;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your day of birth';
                }
                return null;
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(
            width: 60,
            child: TextFormField(
              maxLength: 2,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Month',
                counterText: "",
              ),
              onChanged: (value) {
                setState(() {
                  month = int.tryParse(value);
                  errorMessage = null;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your day of birth';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid month';
                }
                var intValue = int.parse(value);
                if (intValue < 1 || intValue > 12) {
                  return 'Please enter a valid month';
                }
                return null;
              },
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
            child: TextFormField(
              maxLength: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Year',
                counterText: "",
              ),
              onChanged: (value) {
                setState(() {
                  year = int.tryParse(value);
                  errorMessage = null;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your day of birth';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );

    final emailField = TextFormField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Email *',
      ),
      onChanged: (value) {
        setState(() {
          email = value;
          errorMessage = null;
        });
      },
      validator: (value) =>
          (value ?? "").isEmpty ? 'Please enter your email' : null,
    );

    final passwordField = TextFormField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Password *',
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
          labelText: 'Confirm Password *',
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
                  labelText: 'School *',
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
            child: firstNameField,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: lastNameField,
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 8.0, 0, 0),
            child: Text("Date of Birth *"),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 0),
            child: dateOfBirthRow,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: emailField,
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
                  setState(() {
                    errorMessage = null;
                    waitingResponse = true;
                    dateOfBirth = DateTime(year!, month!, day!);
                  });
                  context
                      .read<AuthService>()
                      .registerUser(
                        firstName: firstName,
                        lastName: lastName,
                        dateOfBirth: dateOfBirth!,
                        email: email,
                        password: password,
                        school: school!,
                      )
                      .then((value) {
                    setState(() {
                      waitingResponse = false;
                    });
                    widget.onRegistration();
                  }).onError((error, stackTrace) {
                    setState(() {
                      waitingResponse = false;
                      errorMessage = error.toString();
                    });
                  });
                },
                child: const Text('Register'),
              ),
            ),
        ],
      ),
    );
  }
}
