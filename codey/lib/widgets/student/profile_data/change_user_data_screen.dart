import 'package:codey/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangeUserDataScreen extends StatelessWidget {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dayController = TextEditingController();
  final monthController = TextEditingController();
  final yearController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  ChangeUserDataScreen({
    Key? key,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
  }) : super(key: key) {
    firstNameController.text = firstName ?? '';
    lastNameController.text = lastName ?? '';
    dayController.text = dateOfBirth?.day.toString() ?? '';
    monthController.text = dateOfBirth?.month.toString() ?? '';
    yearController.text = dateOfBirth?.year.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: Theme.of(context).colorScheme.background,
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
                    ),
                    controller: firstNameController,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text("Prezime:", style: TextStyle(fontSize: 16)),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Unesite svoje prezime',
                    ),
                    controller: lastNameController,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child:
                        Text("Datum rođenja:", style: TextStyle(fontSize: 16)),
                  ),
                  dateOfBirthRow,
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      context
                          .read<UserService>()
                          .changeUserData(
                            firstName: firstNameController.text,
                            lastName: lastNameController.text,
                            dateOfBirth: DateTime(
                              int.parse(yearController.text),
                              int.parse(monthController.text),
                              int.parse(dayController.text),
                            ),
                          )
                          .then((newUser) {
                        Navigator.of(context).pop(newUser);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Podatci uspješno promijenjeni'),
                          ),
                        );
                      }).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error.toString()),
                          ),
                        );
                      });
                    },
                    child: const Text('Promijeni podatke'),
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
