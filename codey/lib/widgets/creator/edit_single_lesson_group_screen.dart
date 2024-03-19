import 'package:codey/models/entities/lesson.dart';
import 'package:codey/models/entities/lesson_group.dart';
import 'package:codey/services/lesson_groups_service.dart';
import 'package:codey/services/lessons_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pick_lesson_screen.dart';

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
  List<Lesson> lessons = [];
  bool nameEditable = false;
  String? nameEdited;
  bool tipsEditable = false;
  String? tipsEdited;
  bool lessonsEditable = false;
  List<Lesson>? lessonsEdited;

  @override
  void initState() {
    super.initState();
    final lessonsService = context.read<LessonsService>();
    lessonsService
        .getLessonsByIds(widget.lessonGroup.lessons)
        .then((lessonsInGroup) => {lessons = lessonsInGroup});
  }

  @override
  Widget build(BuildContext context) {
    final nameRow = _generateNameRow();
    final tipsRow = _generateTipsRow();
    final lessonsRow = _generateLessonsRow();

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit lesson group ${widget.lessonGroup.id}'),
      ),
      body: Center(
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
                child: lessonsRow,
              ),
              ElevatedButton(
                  onPressed: () {
                    final lessonGroup = LessonGroup(
                        id: widget.lessonGroup.id,
                        name: nameEdited ?? widget.lessonGroup.name,
                        tips: tipsEdited ?? widget.lessonGroup.tips,
                        lessons: lessonsEdited == null
                            ? widget.lessonGroup.lessons
                            : lessonsEdited!.map((e) => e.id).toList(),
                        order: widget.lessonGroup.order);
                    context
                        .read<LessonGroupsService>()
                        .updateLessonGroup(lessonGroup);
                    Navigator.pop(context);
                  },
                  child: const Text('Save'))
            ],
          ),
        ),
      ),
    );
  }

  Row _generateLessonsRow() {
    final lessonsRow = Row(
      children: [
        IconButton(
            onPressed: () {
              setState(() {
                lessonsEdited = List.of(lessons);
                lessonsEditable = !lessonsEditable;
              });
            },
            icon: Icon(lessonsEditable ? Icons.undo : Icons.edit)),
        const Text('LESSONS: ', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      .map((e) => ListTile(
                            key: ValueKey(e),
                            title: Text("${e.name} (${e.id})"),
                            leading: IconButton(
                              onPressed: () {
                                setState(() {
                                  lessonsEdited!.remove(e);
                                });
                              },
                              icon: const Icon(Icons.clear),
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
          IconButton(
            onPressed: () {
              setState(() {
                lessonsEditable = false;
                widget.lessonGroup.lessons =
                    lessonsEdited!.map((e) => e.id).toList();
                lessons = List.of(lessonsEdited!);
              });
            },
            icon: const Icon(Icons.save),
          )
        ] else
          Text(widget.lessonGroup.lessons.map((e) => e.toString()).join(", ")),
      ],
    );
    return lessonsRow;
  }

  Row _generateTipsRow() {
    final tipsRow = Row(
      children: [
        IconButton(
            onPressed: () {
              setState(() {
                tipsEditable = !tipsEditable;
                tipsEdited = widget.lessonGroup.tips;
              });
            },
            icon: Icon(tipsEditable ? Icons.undo : Icons.edit)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TIPS: ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              tipsEditable
                  ? TextFormField(
                      initialValue: widget.lessonGroup.tips,
                      maxLines: 10,
                      onChanged: (value) {
                        tipsEdited = value;
                      },
                    )
                  : Text(
                      widget.lessonGroup.tips,
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
                    ),
            ],
          ),
        ),
        if (tipsEditable)
          IconButton(
            onPressed: () {
              setState(() {
                tipsEditable = false;
                widget.lessonGroup.tips = tipsEdited!;
              });
            },
            icon: const Icon(Icons.save),
          ),
      ],
    );
    return tipsRow;
  }

  Row _generateNameRow() {
    final nameRow = Row(
      children: [
        IconButton(
            onPressed: () {
              setState(() {
                nameEditable = !nameEditable;
                nameEdited = widget.lessonGroup.name;
              });
            },
            icon: Icon(nameEditable ? Icons.undo : Icons.edit)),
        const Text('NAME: ', style: TextStyle(fontWeight: FontWeight.bold)),
        if (nameEditable) ...[
          Expanded(
            child: TextFormField(
              initialValue: widget.lessonGroup.name,
              maxLength: 200,
              maxLines: 1,
              onChanged: (value) {
                nameEdited = value;
              },
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                nameEditable = false;
                widget.lessonGroup.name = nameEdited!;
              });
            },
            icon: const Icon(Icons.save),
          )
        ] else
          Text(widget.lessonGroup.name),
      ],
    );
    return nameRow;
  }
}
