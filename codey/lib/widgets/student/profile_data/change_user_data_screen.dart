import 'package:codey/services/user_service.dart';
import 'package:codey/widgets/student/profile_data/change_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangeUserDataScreen extends StatelessWidget {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final leaderboardNameController = TextEditingController();
  final dayController = TextEditingController();
  final monthController = TextEditingController();
  final yearController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final String? _firstName;
  final String? _lastName;

  ChangeUserDataScreen({
    Key? key,
    String? firstName,
    String? lastName,
    String? leaderboardName,
    DateTime? dateOfBirth,
  })  : _firstName = firstName,
        _lastName = lastName,
        super(key: key) {
    firstNameController.text = firstName ?? '';
    lastNameController.text = lastName ?? '';
    leaderboardNameController.text = leaderboardName ?? '';
    dayController.text = dateOfBirth?.day.toString() ?? '';
    monthController.text = dateOfBirth?.month.toString() ?? '';
    yearController.text = dateOfBirth?.year.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    bool dobAllEmpty() =>
        dayController.text.isEmpty &&
        monthController.text.isEmpty &&
        yearController.text.isEmpty;

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
                labelText: 'D',
                counterText: "",
              ),
              controller: dayController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  if (dobAllEmpty()) return null;
                  return 'Molimo unesite dan rođenja';
                }
                if (int.tryParse(value) == null) {
                  return 'Molimo unesite ispravan dan';
                }
                var intValue = int.parse(value);
                if (intValue < 1 || intValue > 31) {
                  return 'Molimo unesite ispravan dan';
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
                labelText: 'M',
                counterText: "",
              ),
              controller: monthController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  if (dobAllEmpty()) return null;
                  return 'Molimo unesite mjesec rođenja';
                }
                if (int.tryParse(value) == null) {
                  return 'Molimo unesite ispravan mjesec';
                }
                var intValue = int.parse(value);
                if (intValue < 1 || intValue > 12) {
                  return 'Molimo unesite ispravan mjesec';
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
                labelText: 'Godina',
                counterText: "",
              ),
              controller: yearController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  if (dobAllEmpty()) return null;
                  return 'Molimo unesite godinu rođenja';
                }
                if (int.tryParse(value) == null) {
                  return 'Molimo unesite ispravnu godinu';
                }
                var intValue = int.parse(value);
                if (intValue < 1900 || intValue > DateTime.now().year) {
                  return 'Molimo unesite ispravnu godinu';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Promjena podataka'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        titleTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary, fontSize: 18),
        actionsIconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 80.0, vertical: 40.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text("Ime:", style: TextStyle(fontSize: 16)),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Unesite svoje ime',
                      counterText: "",
                    ),
                    controller: firstNameController,
                    maxLength: 20,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Molimo unesite ime';
                      }
                      if (value.trim().length > 20) {
                        return 'Najviše 20 znakova';
                      }
                      return null;
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text("Prezime:", style: TextStyle(fontSize: 16)),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Unesite svoje prezime',
                      counterText: "",
                    ),
                    controller: lastNameController,
                    maxLength: 20,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Molimo unesite prezime';
                      }
                      if (value.trim().length > 20) {
                        return 'Najviše 20 znakova';
                      }
                      return null;
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child:
                        Text("Datum rođenja:", style: TextStyle(fontSize: 16)),
                  ),
                  dateOfBirthRow,
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text("Ime na ljestvici:",
                        style: TextStyle(fontSize: 16)),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: 'Zadano: '
                                '${(_firstName ?? '').trim()} '
                                '${(_lastName ?? '').trim()}'
                                    .trim(),
                          ),
                          controller: leaderboardNameController,
                          maxLength: 30,
                          validator: (value) {
                            if (value == null || value.isEmpty) return null;
                            if (value.trim().isEmpty) {
                              return 'Ime na ljestvici ne smije biti prazno';
                            }
                            if (value.trim().length > 30) {
                              return 'Najviše 30 znakova';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Vrati zadano',
                        icon: const Icon(Icons.restart_alt),
                        onPressed: () {
                          final messenger = ScaffoldMessenger.of(context);
                          context
                              .read<UserService>()
                              .resetLeaderboardName()
                              .then((_) {
                            leaderboardNameController.clear();
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Ime na ljestvici vraćeno'),
                              ),
                            );
                          }).catchError((error) {
                            messenger.showSnackBar(
                              SnackBar(content: Text(error.toString())),
                            );
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);
                      final leaderboardNameInput =
                          leaderboardNameController.text.trim();
                      final hasDob = dayController.text.isNotEmpty &&
                          monthController.text.isNotEmpty &&
                          yearController.text.isNotEmpty;
                      context
                          .read<UserService>()
                          .changeUserData(
                            firstName: firstNameController.text.trim(),
                            lastName: lastNameController.text.trim(),
                            dateOfBirth: hasDob
                                ? DateTime(
                                    int.parse(yearController.text),
                                    int.parse(monthController.text),
                                    int.parse(dayController.text),
                                  )
                                : null,
                            leaderboardName: leaderboardNameInput.isEmpty
                                ? null
                                : leaderboardNameInput,
                          )
                          .then((newUser) {
                        navigator.pop(newUser);
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Podatci uspješno spremljeni'),
                          ),
                        );
                      }).catchError((error) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(error.toString()),
                          ),
                        );
                      });
                    },
                    child: const Text('Spremi podatke'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChangePasswordScreen(),
                        ),
                      );
                    },
                    child: const Text('Promijeni lozinku'),
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
