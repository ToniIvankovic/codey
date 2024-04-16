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
                  horizontal: paddingHorizontal,
                  vertical: paddingVertical,
                ),
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
                              for (var otherGroup in data!) {
                                if (otherGroup.lessonGroup.id !=
                                    group.lessonGroup.id) {
                                  otherGroup.isExpanded = false;
                                }
                              }
                            })
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
            Padding(
              padding: EdgeInsets.only(top: tileSize + 2 * paddingVertical),
            ),
          ],
        ),
        for (int i = 0; i < data!.length; i++) ...[
          Positioned(
            top: 10 +
                (i + 1) * (tileSize + 2 * paddingVertical) -
                paddingVertical,
            child: _FloatingWindow(
              isVisible: () => data![i].isExpanded,
              onVisibleChange: (newValue) => setState(() {
                data![i].isExpanded = newValue;
              }),
              lessonGroup: data![i].lessonGroup,
            ),
          ),
        ],
      ],
    );
  }
}

class _FloatingWindow extends StatefulWidget {
  final bool Function() isVisible;
  final LessonGroup lessonGroup;
  final void Function(bool) onVisibleChange;

  const _FloatingWindow({
    Key? key,
    required this.isVisible,
    required this.lessonGroup,
    required this.onVisibleChange,
  }) : super(key: key);

  @override
  State<_FloatingWindow> createState() => _FloatingWindowState();
}

class _FloatingWindowState extends State<_FloatingWindow> {
  set isVisible(bool newValue) {
    widget.onVisibleChange(newValue);
  }

  bool get isVisible => widget.isVisible();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      maintainState: true,
      maintainAnimation: true,
      visible: isVisible,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: isVisible ? 1.0 : 0.0,
        child: Container(
          width: 2.5 * 125.0,
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
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Text(
                        widget.lessonGroup.name,
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
                                  lessonGroup: widget.lessonGroup,
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
                                  lessonGroup: widget.lessonGroup,
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
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  onPressed: () => isVisible = false,
                  icon: const Icon(Icons.clear),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
