import 'package:codey/models/entities/app_user.dart';
import 'package:codey/models/entities/lesson.dart';
import 'package:codey/models/entities/lesson_group.dart';
import 'package:codey/services/lesson_groups_service.dart';
import 'package:codey/services/lessons_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewSingleStudentScreen extends StatefulWidget {
  final AppUser student;
  const ViewSingleStudentScreen({super.key, required this.student});

  @override
  State<ViewSingleStudentScreen> createState() =>
      _ViewSingleStudentScreenState();
}

class _ViewSingleStudentScreenState extends State<ViewSingleStudentScreen> {
  Lesson? highestLesson;
  LessonGroup? highestLessonGroup;
  bool specificDataLoading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      specificDataLoading = true;
    });
    fetchHighestLesson().then((value) {
      fetchHighestLessonGroup().then((value) {
        setState(() {
          specificDataLoading = false;
        });
      });
    });
  }

  Future<void> fetchHighestLesson() async {
    if (widget.student.highestLessonId == null) {
      return;
    }
    if (widget.student.highestLessonId == 99999 ||
        widget.student.highestLessonId == 99998) {
      highestLesson = Lesson(
        id: widget.student.highestLessonId!,
        name: "ADAPTIVNA",
        exerciseIds: [],
      );
      return;
    }
    var lessons = await context
        .read<LessonsService>()
        .getLessonsByIds([widget.student.highestLessonId!]);
    setState(() {
      highestLesson = lessons[0];
    });
  }

  Future<void> fetchHighestLessonGroup() async {
    if (widget.student.highestLessonGroupId == null) {
      return;
    }
    var lgr = await context
        .read<LessonGroupsService>()
        .getLessonGroupById(widget.student.highestLessonGroupId!);

    setState(() {
      highestLessonGroup = lgr;
    });
  }

  @override
  Widget build(BuildContext context) {
    var solvedLessons = widget.student.xpHistory.length;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.student.firstName} ${widget.student.lastName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(50.0),
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
                    '${widget.student.firstName} ${widget.student.lastName}',
                    style: const TextStyle(fontSize: 20),
                    overflow: TextOverflow.fade,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Korisničko ime: ${widget.student.email}',
                    overflow: TextOverflow.fade,
                  ),
                ],
              ),
            ),
            if (specificDataLoading)
              const CircularProgressIndicator()
            else ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: highestLesson != null
                    ? Text(
                        'Najviša lekcija: ${highestLesson!.name}',
                        overflow: TextOverflow.fade,
                      )
                    : const Text('Najviša lekcija: NEMA'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: highestLessonGroup != null
                    ? Text(
                        'Najviša dovršena cjelina: ${highestLessonGroup!.name} (${highestLessonGroup!.order})',
                        overflow: TextOverflow.fade,
                      )
                    : const Text('Najviša dovršena cjelina: NEMA'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Riješene lekcije: $solvedLessons',
                  overflow: TextOverflow.fade,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Ukupno XP: ${widget.student.totalXp}',
                  overflow: TextOverflow.fade,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
