import 'package:codey/models/entities/class.dart';
import 'package:codey/widgets/teacher/edit_class_screen.dart';
import 'package:flutter/material.dart';

class ViewSingleClassScreen extends StatefulWidget {
  final Class initialClassData;
  const ViewSingleClassScreen({super.key, required this.initialClassData});

  @override
  State<ViewSingleClassScreen> createState() => _ViewSingleClassScreenState();
}

class _ViewSingleClassScreenState extends State<ViewSingleClassScreen> {
  late Class classData;

  @override
  void initState() {
    super.initState();
    classData = widget.initialClassData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Razred ${classData.name}'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Naziv razreda: ${classData.name}',
                      style: const TextStyle(fontSize: 18),
                      overflow: TextOverflow.fade,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'ID: ${classData.id}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Učenici:',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: classData.studentEmails.length,
                itemBuilder: (context, index) {
                  final student = classData.studentEmails[index];
                  return ListTile(
                    title: Text(student),
                  );
                },
              ),
              //EDIT CLASS
              TextButton.icon(
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (context) => EditClassScreen(
                          classData: classData,
                        ),
                      ),
                    )
                        .then(
                      (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          classData = value as Class;
                        });
                      },
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Uredi razred')),
            ],
          ),
        ),
      ),
    );
  }
}
