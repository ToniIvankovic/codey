import 'package:codey/models/exceptions/invalid_data_exception.dart';
import 'package:codey/services/admin_functions_service.dart';
import 'package:codey/services/user_interaction_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateTeacherScreen extends StatefulWidget {
  const CreateTeacherScreen({Key? key}) : super(key: key);

  @override
  State<CreateTeacherScreen> createState() => _CreateTeacherScreenState();
}

class _CreateTeacherScreenState extends State<CreateTeacherScreen> {
  String firstName = "";
  String lastName = "";
  String email = "";
  String password = "";
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Teacher'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'First Name'),
            onChanged: (value) {
              firstName = value;
            },
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Last Name'),
            onChanged: (value) {
              lastName = value;
            },
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Email'),
            onChanged: (value) {
              email = value;
            },
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Password'),
            onChanged: (value) {
              password = value;
            },
          ),
          if (schools.isNotEmpty)
            Row(
              children: [
                Expanded(
                  child: FormField<String>(
                    builder: (FormFieldState<String> state) {
                      return DropdownButtonFormField<String>(
                        value: school,
                        items: schools
                            .map((schoolItem) => DropdownMenuItem(
                                  value: schoolItem,
                                  child: Text(schoolItem),
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
            ),
          ElevatedButton(
            onPressed: () {
              //TODO: validate form data
              context
                  .read<AdminFunctionsService>()
                  .registerTeacher(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    password: password,
                    school: school != null
                        ? school!
                        : throw InvalidDataException('Please select a school'),
                  )
                  .then((value) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Teacher created successfully'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $error'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              });
            },
            child: const Text('Create Teacher'),
          ),
        ],
      ),
    );
  }
}
