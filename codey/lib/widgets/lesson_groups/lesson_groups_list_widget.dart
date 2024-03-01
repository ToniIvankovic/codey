import 'package:codey/models/entities/lesson_group.dart';
import 'package:codey/widgets/lessons/lessons_screen.dart';
import 'package:flutter/material.dart';

class ListItem {
  ListItem({
    required this.lessonGroup,
    required this.clickable,
    this.isExpanded = false,
  });

  final LessonGroup lessonGroup;
  final bool clickable;
  bool isExpanded;
}

class LessonGroupsListView extends StatefulWidget {
  final List<ListItem> data;

  const LessonGroupsListView({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<LessonGroupsListView> createState() => _LessonGroupsListViewState();
}

class _LessonGroupsListViewState extends State<LessonGroupsListView> {
  late final List<ListItem> data;
  @override
  void initState() {
    super.initState();
    data = widget.data; // Initialize data from the parent widget
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            // Set the current panel, close all others
            for (int i = 0; i < data.length; i++) {
              data[i].isExpanded = (i == index) ? isExpanded : false;
            }
          });
        },
        children: data.map<ExpansionPanel>((ListItem item) {
          return ExpansionPanel(
            isExpanded: item.isExpanded,
            canTapOnHeader: item.clickable,
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Text(
                  item.lessonGroup.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: item.clickable ? null : Colors.grey,
                  ),
                ),
              );
            },
            body: ListTile(
                title: Text(
                  item.lessonGroup.tips,
                  style: TextStyle(color: item.clickable ? null : Colors.grey),
                ),
                onTap: () {
                  if (item.clickable) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LessonsScreen(lessonGroup: item.lessonGroup),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                          content: Text(
                              'You need to complete the previous lesson group first'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                  }
                }),
          );
        }).toList(),
      ),
    );
  }
}
