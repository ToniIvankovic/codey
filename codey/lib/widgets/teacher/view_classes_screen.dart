import 'package:flutter/material.dart';

class ViewClassesScreen extends StatefulWidget {
  const ViewClassesScreen({super.key});

  @override
  State<ViewClassesScreen> createState() => _ViewClassesScreenState();
}

class _ViewClassesScreenState extends State<ViewClassesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Classes'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Classes will be displayed here'),
          ],
        ),
      ),
    );
  }
}
