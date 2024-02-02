import 'package:codey/models/app_user.dart';
import 'package:codey/models/exceptions/unauthorized_exception.dart';
import 'package:codey/models/lesson_group.dart';
import 'package:codey/repositories/lesson_groups_repository.dart';
import 'package:codey/services/auth_service.dart';
import 'package:codey/services/user_service.dart';
import 'package:codey/widgets/screens/lessons_screen.dart';
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

class LessonGroupsList extends StatelessWidget {
  final String title;
  final VoidCallback onLogout;

  const LessonGroupsList({
    super.key,
    required this.title,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    LessonGroupsRepository lessonGroupsRepository =
        context.read<LessonGroupsRepository>();
    List<ListItem> data = [];
    final authService = context.read<AuthService>();
    final userService = context.read<UserService>();
    AppUser user;

    try {
      return FutureBuilder<List<dynamic>>(
        future: Future.wait([
          lessonGroupsRepository.lessonGroups,
          userService.user
        ]), // Call the getUser method from AuthService to get the user
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(
              strokeWidth: 5,
            );
          } else if (snapshot.hasError) {
            if (snapshot.error is UnauthenticatedException) {
              authService.logout();
              onLogout();
            }
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.data == null) {
            return const Text('No data');
          } else {
            List<LessonGroup> lg = snapshot.data![0];
            user = snapshot.data![1];

            data = lg
                .map<ListItem>(
                  (item) => ListItem(
                    lessonGroup: item,
                    clickable: item.id <= user.nextLessonGroupId,
                    isExpanded: false,
                  ),
                )
                .toList();

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(user.email),
                Text(
                    "Last lesson: ${user.highestLessonId?.toString() ?? 'Just begun'}"),
                Text(
                    "Last lesson group: ${user.highestLessonGroupId?.toString() ?? 'Just begun'}"),
                Text("Next lesson: ${user.nextLessonId.toString()}"),
                Text("Next lesson group: ${user.nextLessonGroupId.toString()}"),
                LessonGroupsListView(data: data),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      authService
                          .logout(); // Call the logout method from AuthService
                      onLogout();
                    },
                    child: const Text('Logout'),
                  ),
                ),
              ],
            );
          }
        },
      );
    } on UnauthenticatedException catch (e) {
      authService.logout();
      onLogout();
      return Text('Error: $e');
    }
  }
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
  late List<ListItem> data;
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
            data[index].isExpanded = isExpanded;
            for (int i = 0; i < data.length; i++) {
              if (i != index) {
                data[i].isExpanded = false;
              }
            }
          });
        },
        children: data.map<ExpansionPanel>((ListItem item) {
          return ExpansionPanel(
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
                onTap: item.clickable
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LessonsScreen(lessonGroup: item.lessonGroup),
                          ),
                        );
                      }
                    : () {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'You need to complete the previous lesson group first'),
                            ),
                          );
                      }),
            isExpanded: item.isExpanded,
            canTapOnHeader: item.clickable,
          );
        }).toList(),
      ),
    );
  }
}
