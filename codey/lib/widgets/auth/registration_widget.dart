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
        labelText: 'Ime *',
      ),
      onChanged: (value) {
        setState(() {
          firstName = value;
          errorMessage = null;
        });
      },
      validator: (value) => (value ?? "").isEmpty ? 'Molimo unesite ime' : null,
    );
    final lastNameField = TextFormField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Prezime *',
      ),
      onChanged: (value) {
        setState(() {
          lastName = value;
          errorMessage = null;
        });
      },
      validator: (value) =>
          (value ?? "").isEmpty ? 'Molimo unesite prezime' : null,
    );

    DateTime? dateOfBirth;
    if (year != null && month != null && day != null) {
      dateOfBirth = DateTime(year!, month!, day!);
    }
    final dateOfBirthRow = FormField(
      builder: (FormFieldState state) {
        return Column(
          children: [
            if (state.errorText != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(0,0,0,10),
                child: Text(
                  state.errorText.toString(),
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                ),
              ),
            Row(
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
                        labelText: 'D',
                        counterText: "",
                      ),
                      onChanged: (value) {
                        setState(() {
                          day = int.tryParse(value);
                          errorMessage = null;
                        });
                      },
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return 'Molimo unesite dan rođenja';
                      //   }
                      //   if (int.tryParse(value) == null) {
                      //     return 'Molimo unesite ispravan dan';
                      //   }
                      //   var intValue = int.parse(value);
                      //   if (intValue < 1 || intValue > 31) {
                      //     return 'Molimo unesite ispravan dan';
                      //   }
                      //   return null;
                      // },
                      validator: (value) {
                        return state.hasError ? "" : null;
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
                        labelText: 'M',
                        counterText: "",
                      ),
                      onChanged: (value) {
                        setState(() {
                          month = int.tryParse(value);
                          errorMessage = null;
                        });
                      },
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return 'Molimo unesite mjesec rođenja';
                      //   }
                      //   if (int.tryParse(value) == null) {
                      //     return 'Molimo unesite ispravan mjesec';
                      //   }
                      //   var intValue = int.parse(value);
                      //   if (intValue < 1 || intValue > 12) {
                      //     return 'Molimo unesite ispravan mjesec';
                      //   }
                      //   return null;
                      // },
                      validator: (value) {
                        return state.hasError ? "" : null;
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
                        labelText: 'Godina',
                        counterText: "",
                      ),
                      onChanged: (value) {
                        setState(() {
                          year = int.tryParse(value);
                          errorMessage = null;
                        });
                      },
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return 'Molimo unesite godinu rođenja';
                      //   }
                      //   if (int.tryParse(value) == null) {
                      //     return 'Molimo unesite ispravnu godinu';
                      //   }
                      //   var intValue = int.parse(value);
                      //   if (intValue < 1900 || intValue > DateTime.now().year) {
                      //     return 'Molimo unesite ispravnu godinu';
                      //   }
                      //   return null;
                      // },
                      validator: (value) {
                        return state.hasError ? "" : null;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
      validator: (value) {
        if (day == null || month == null || year == null) {
          return 'Molimo unesite datum rođenja';
        }
        var date = DateTime(year!, month!, day!);
        if (date.day != day || date.month != month || date.year != year) {
          return 'Molimo unesite ispravan datum';
        }
        if (date.isAfter(DateTime.now())) {
          return 'Datum rođenja ne može biti u budućnosti';
        }
        return null;
      },
    );

    final emailField = TextFormField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Korisničko ime *',
      ),
      onChanged: (value) {
        setState(() {
          email = value;
          errorMessage = null;
        });
      },
      validator: (value) =>
          (value ?? "").isEmpty ? 'Molimo unesite e-mail' : null,
    );

    final passwordField = TextFormField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Lozinka *',
      ),
      obscureText: true,
      onChanged: (value) {
        setState(() {
          password = value;
          errorMessage = null;
        });
      },
      validator: (value) =>
          (value ?? "").isEmpty ? 'Molimo unesite lozinku' : null,
    );

    final confirmPasswordField = TextFormField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Ponovljena lozinka *',
        ),
        obscureText: true,
        onChanged: (value) {
          setState(() {
            confirmPassword = value;
            errorMessage = null;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Molimo ponovite lozinku';
          }
          if (value != password) {
            return 'Lozinke se ne podudaraju';
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
                  labelText: 'Škola *',
                  errorText: state.errorText,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Molimo odaberite školu';
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
            child: Text("Datum rođenja *"),
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
                child: const Text('Registracija'),
              ),
            ),
        ],
      ),
    );
  }
}
