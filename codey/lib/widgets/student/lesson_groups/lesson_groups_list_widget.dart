import 'package:codey/models/entities/app_user.dart';
import 'package:codey/models/entities/lesson_group.dart';
import 'package:codey/services/lesson_groups_service.dart';
import 'package:codey/widgets/student/lessons/lessons_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  final AppUser user;

  const LessonGroupsListView({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<LessonGroupsListView> createState() => _LessonGroupsListViewState();
}

class _LessonGroupsListViewState extends State<LessonGroupsListView> {
  List<ListItem>? data;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var lessonGroupsService = context.read<LessonGroupsService>();
    if (data == null) {
      lessonGroupsService.getAllLessonGroups().then((value) {
        List<LessonGroup> lessonGroups = value;
        setState(() {
          data = lessonGroups
              .map<ListItem>(
                (item) => ListItem(
                  lessonGroup: item,
                  clickable: item.order <=
                      (lessonGroups
                          .where((lessonGroup) =>
                              lessonGroup.id == widget.user.nextLessonGroupId)
                          .first
                          .order),
                  isExpanded: false,
                ),
              )
              .toList();
        });
      });
      return const CircularProgressIndicator(
        strokeWidth: 5,
      );
    }
    return SingleChildScrollView(
      child: ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            // Set the current panel, close all others
            for (int i = 0; i < data!.length; i++) {
              data![i].isExpanded = (i == index) ? isExpanded : false;
            }
          });
        },
        children: data!.map<ExpansionPanel>((ListItem item) {
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
