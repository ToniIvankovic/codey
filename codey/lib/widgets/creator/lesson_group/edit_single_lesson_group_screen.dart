import 'package:codey/models/entities/lesson.dart';
import 'package:codey/models/entities/lesson_group.dart';
import 'package:codey/services/lesson_groups_service.dart';
import 'package:codey/services/lessons_service.dart';
import 'package:codey/widgets/creator/lesson/edit_single_lesson_screen.dart';
import 'package:codey/widgets/student/lesson_groups/lesson_group_tips_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../lesson/pick_lesson_screen.dart';

class EditSingleLessonGroupScreen extends StatefulWidget {
  const EditSingleLessonGroupScreen({
    super.key,
    required this.lessonGroup,
  });
  final LessonGroup lessonGroup;

  @override
  State<EditSingleLessonGroupScreen> createState() =>
      _EditSingleLessonGroupScreenState();
}

class _EditSingleLessonGroupScreenState
    extends State<EditSingleLessonGroupScreen> {
  List<Lesson> localLessons = [];
  String localName = '';
  String? localTips = '';
  bool nameEditable = false;
  bool tipsEditable = false;
  bool lessonsEditable = false;
  String? nameEdited;
  String? tipsEdited;
  List<Lesson>? lessonsEdited;
  String? nameEditedCommit;
  String? tipsEditedCommit;
  List<Lesson>? lessonsEditedCommit;
  bool adaptive = false;

  @override
  void initState() {
    super.initState();
    final lessonsService = context.read<LessonsService>();
    lessonsService.getLessonsByIds(widget.lessonGroup.lessons).then(
        (lessonsInGroup) => setState(() => localLessons = lessonsInGroup));
    localName = widget.lessonGroup.name;
    localTips = widget.lessonGroup.tips;
    adaptive = widget.lessonGroup.adaptive;
  }

  @override
  Widget build(BuildContext context) {
    final nameRow = _generateNameRow();
    final tipsRow = _generateTipsRow();
    final lessonsRow = _generateLessonsRow();
    final bool madeEdits = nameEditedCommit == null &&
        tipsEditedCommit == null &&
        lessonsEditedCommit == null &&
        adaptive == widget.lessonGroup.adaptive;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit lesson group ${widget.lessonGroup.id}'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: nameRow,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: tipsRow,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    children: [
                      const Text("Adaptive:"),
                      Checkbox(
                        value: adaptive,
                        onChanged: (value) => setState(() {
                          adaptive = value!;
                        }),
                      ),
                    ],
                  ),
                ),

                if (!adaptive)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: lessonsRow,
                  ),
                // COMMIT CHANGES TO BE
                ElevatedButton(
                    onPressed: madeEdits
                        ? null
                        : () {
                            final lessonGroup = LessonGroup(
                              id: widget.lessonGroup.id,
                              name: nameEdited ?? widget.lessonGroup.name,
                              tips: tipsEdited ?? widget.lessonGroup.tips,
                              lessons: lessonsEdited == null
                                  ? widget.lessonGroup.lessons
                                  : lessonsEdited!.map((e) => e.id).toList(),
                              order: widget.lessonGroup.order,
                              adaptive: adaptive,
                            );

                            // Save changes on BE
                            context
                                .read<LessonGroupsService>()
                                .updateLessonGroup(lessonGroup)
                                .then((value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Lesson group updated"),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              Navigator.pop(context, value);
                            }).catchError((error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $error'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              Navigator.pop(context, null);
                            });
                          },
                    child: const Text('Save'))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row _generateNameRow() {
    final nameRow = Row(
      children: [
        // EDIT/UNDO BUTTON
        IconButton(
            onPressed: () {
              setState(() {
                nameEditable = !nameEditable;
                nameEdited = localName;
              });
            },
            icon: Icon(nameEditable ? Icons.undo : Icons.edit)),
        // TITLE
        const Text('NAME: ', style: TextStyle(fontWeight: FontWeight.bold)),
        if (nameEditable) ...[
          Expanded(
            // EDITABLE TEXT FIELD
            child: TextFormField(
              initialValue: localName,
              maxLength: 200,
              maxLines: 1,
              onChanged: (value) {
                nameEdited = value;
              },
            ),
          ),
          // SAVE CHANGES LOCALLY
          IconButton(
            onPressed: () {
              setState(() {
                nameEditable = false;
                nameEditedCommit = nameEdited!;
                localName = nameEditedCommit!;
                if (nameEditedCommit == widget.lessonGroup.name) {
                  nameEditedCommit = null;
                }
              });
            },
            icon: const Icon(Icons.save),
          )
        ] else
          // NON-EDITABLE TEXT
          Text(localName),
      ],
    );
    return nameRow;
  }

  Row _generateTipsRow() {
    final tipsRow = Row(
      children: [
        // EDIT/UNDO BUTTON
        Column(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  tipsEditable = !tipsEditable;
                  tipsEdited = localTips;
                });
              },
              icon: Icon(tipsEditable ? Icons.undo : Icons.edit),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LessonGroupTipsScreen(
                      lessonGroup: LessonGroup(
                        id: widget.lessonGroup.id,
                        name: widget.lessonGroup.name,
                        tips: localTips,
                        lessons: widget.lessonGroup.lessons,
                        order: widget.lessonGroup.order,
                        adaptive: widget.lessonGroup.adaptive,
                      ),
                      lessonGroupFinished: true,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.remove_red_eye),
            ),
          ],
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TITLE
              const Text('TIPS: ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              tipsEditable
                  // EDITABLE TEXT FIELD
                  ? TextFormField(
                      initialValue: tipsEdited,
                      maxLines: 10,
                      onChanged: (value) {
                        tipsEdited = value;
                      },
                    )
                  // NON-EDITABLE TEXT
                  : Text(
                      localTips ?? '',
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
                    ),
            ],
          ),
        ),
        // SAVE CHANGES LOCALLY
        if (tipsEditable)
          IconButton(
            onPressed: () {
              setState(() {
                tipsEditable = false;
                tipsEditedCommit = tipsEdited!;
                localTips = tipsEditedCommit!;
                if (tipsEditedCommit == widget.lessonGroup.tips) {
                  tipsEditedCommit = null;
                }
              });
            },
            icon: const Icon(Icons.save),
          ),
      ],
    );
    return tipsRow;
  }

  Row _generateLessonsRow() {
    final lessonsRow = Row(
      children: [
        // EDIT/UNDO BUTTON
        IconButton(
            onPressed: () {
              setState(() {
                lessonsEdited = List.of(localLessons);
                lessonsEditable = !lessonsEditable;
              });
            },
            icon: Icon(lessonsEditable ? Icons.undo : Icons.edit)),
        // TITLE
        const Text('LESSONS: ', style: TextStyle(fontWeight: FontWeight.bold)),
        // EDITABLE LIST
        if (lessonsEditable) ...[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReorderableListView(
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final Lesson item = lessonsEdited!.removeAt(oldIndex);
                      lessonsEdited!.insert(newIndex, item);
                    });
                  },
                  shrinkWrap: true,
                  children: lessonsEdited!
                      .map((lesson) => ListTile(
                            key: ValueKey(lesson),
                            title: Text(lesson.name),
                            subtitle: Text(
                                "${lesson.id}, ${lesson.exerciseIds.length} exercises"),
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // REMOVE LESSON
                                IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      lessonsEdited!.remove(lesson);
                                    });
                                  },
                                ),
                                // EDIT LESSON
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push<Lesson>(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditSingleLessonScreen(lesson),
                                      ),
                                    )
                                        .then((value) {
                                      if (value != null) {
                                        setState(() {
                                          lessonsEdited![lessonsEdited!
                                                  .indexWhere((element) =>
                                                      element.id == value.id)] =
                                              value;
                                        });
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: IconButton(
                      onPressed: () => {
                            Navigator.push<Lesson>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PickLessonScreen(
                                    existingLessons: lessonsEdited!),
                              ),
                            ).then((value) {
                              if (value != null) {
                                setState(() {
                                  lessonsEdited!.add(value);
                                });
                              }
                            })
                          },
                      icon: const Icon(Icons.add)),
                )
              ],
            ),
          ),
          // SAVE CHANGES LOCALLY
          IconButton(
            onPressed: () {
              setState(() {
                lessonsEditable = false;
                lessonsEditedCommit = lessonsEdited!;
                if (listEquals(lessonsEditedCommit!.map((e) => e.id).toList(),
                    widget.lessonGroup.lessons)) {
                  lessonsEditedCommit = null;
                  lessonsEdited = null;
                } else {
                  localLessons = List.of(lessonsEdited!);
                }
              });
            },
            icon: const Icon(Icons.save),
          )
        ] else
          // NON-EDITABLE LIST
          Expanded(
            child: Column(
              children: [
                for (var lesson in localLessons) ...[
                  ListTile(
                    title: Text(lesson.name),
                    subtitle: Text(
                        "${lesson.id}, ${lesson.exerciseIds.length} exercises"),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
    return lessonsRow;
  }
}
