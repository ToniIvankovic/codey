import 'package:codey/models/exceptions/unauthorized_exception.dart';
import 'package:codey/models/lesson_group.dart';
import 'package:codey/repositories/lesson_groups_repository.dart';
import 'package:codey/services/auth_service.dart';
import 'package:codey/widgets/screens/lessons_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListItem {
  ListItem({
    required this.lessonGroup,
    this.isExpanded = false,
  });

  final LessonGroup lessonGroup;
  bool isExpanded;
}

class LessonGroupsList extends StatefulWidget {
  final String title;
  final VoidCallback onLogout;

  const LessonGroupsList({
    super.key,
    required this.title,
    required this.onLogout,
  });

  @override
  State<LessonGroupsList> createState() => _LessonGroupsListState();
}

class _LessonGroupsListState extends State<LessonGroupsList> {
  String? username;

  @override
  Widget build(BuildContext context) {
    LessonGroupsRepository lessonGroupsRepository =
        context.read<LessonGroupsRepository>();
    List<ListItem> data = [];
    final authService = context.read<AuthService>();
    if (username == null) {
      authService.getUserEmail().then((email) {
        print(email);
        setState(() {
          username = email;
        });
      }).catchError((error) {
        print('Error occurred on getting email: $error - Logging out');
        authService.logout();
        widget.onLogout();
      });
    }

    try {
      return FutureBuilder<List<LessonGroup>>(
        future: lessonGroupsRepository.lessonGroups,
        builder:
            (BuildContext context, AsyncSnapshot<List<LessonGroup>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(
              strokeWidth: 5,
            );
          } else if (snapshot.hasError) {
            if (snapshot.error is UnauthenticatedException) {
              authService.logout();
              widget.onLogout();
            }
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.data == null) {
            return const Text('No data');
          } else {
            var lg = snapshot.data!;
            data = lg
                .map<ListItem>(
                  (item) => ListItem(
                    lessonGroup: item,
                    isExpanded: false,
                  ),
                )
                .toList();

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(username!),
                LGListView(data: data),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      authService
                          .logout(); // Call the logout method from AuthService
                      widget.onLogout();
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
      widget.onLogout();
      return Text('Error: $e');
    }
  }
}

class LGListView extends StatefulWidget {
  final List<ListItem> data;

  const LGListView({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<LGListView> createState() => _LGListViewState();
}

class _LGListViewState extends State<LGListView> {
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
            body: ListTile(
              title: Text(item.lessonGroup.tips),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        LessonsScreen(lessonGroup: item.lessonGroup),
                  ),
                );
              },
            ),
            isExpanded: item.isExpanded,
            canTapOnHeader: true,
          );
        }).toList(),
      ),
    );
  }
}
