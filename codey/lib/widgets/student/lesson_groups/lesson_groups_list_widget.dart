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
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 5,
        ),
      );
    }

    double tileSize = 125.0;
    double paddingVertical = 25.0;
    double paddingHorizontal = 10.0;
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            for (var group in data!) ...[
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: paddingHorizontal, vertical: paddingVertical),
                child: Container(
                  constraints: BoxConstraints(
                      minWidth: tileSize,
                      minHeight: tileSize,
                      maxHeight: tileSize,
                      maxWidth: tileSize),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                      ),
                    ),
                    onPressed: group.clickable
                        ? () => setState(() {
                              group.isExpanded = !group.isExpanded;
                            })
                        // () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => LessonsScreen(
                        //           lessonGroup: group.lessonGroup,
                        //         ),
                        //       ),
                        //     );
                        //   }
                        : null,
                    child: Text(
                      group.lessonGroup.name,
                      overflow: TextOverflow.clip,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        for (int i = 0; i < data!.length; i++) ...[
          Positioned(
            top: 10 +
                (i + 1) * (tileSize + 2 * paddingVertical) -
                paddingVertical, // adjust this value to position the cloud widget
            child: Visibility(
              maintainState: true,
              maintainAnimation: true,
              visible: data![i].isExpanded,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 100),
                opacity: data![i].isExpanded ? 1.0 : 0.0,
                child: Container(
                  width: 2.5 * tileSize,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.7),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Text(
                            data![i].lessonGroup.name,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LessonsScreen(
                                      lessonGroup: data![i].lessonGroup,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.lightbulb),
                              label: const Text('Learn'),
                            ),
                            IconButton.filled(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LessonsScreen(
                                      lessonGroup: data![i].lessonGroup,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.play_arrow),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class HoverButton extends StatefulWidget {
  const HoverButton({super.key});

  @override
  _HoverButtonState createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              _isHovering = !_isHovering;
            });
          },
          child: Text('Show cloud'),
        ),
        if (_isHovering)
          Positioned(
            top: 10, // adjust this value to position the cloud widget
            child: Visibility(
              visible: _isHovering,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 100),
                    ),
                  ],
                ),
                child: Center(child: Text('This is a cloud')),
              ),
            ),
          ),
      ],
    );
  }
}
