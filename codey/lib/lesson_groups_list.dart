import 'package:codey/models/lesson_group.dart';
import 'package:codey/repositories/lesson_groups_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
}

class LessonGroupsList extends StatelessWidget {
  const LessonGroupsList({super.key, required this.title});

  final String title;

  Future<List<LessonGroup>> _fetchLessonGroups(context) {
    final lgRepo = Provider.of<LessonGroupsRepository>(context);
    return lgRepo.lessonGroups;
  }

  @override
  Widget build(BuildContext context) {
    List<Item> data = [];
    return FutureBuilder<List<LessonGroup>>(
      future:
          _fetchLessonGroups(context), // Replace this with your actual Future
      builder:
          (BuildContext context, AsyncSnapshot<List<LessonGroup>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(
            strokeWidth: 5,
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.data == null) {
          return const Text('No data');
        } else {
          var lg = snapshot.data!;
          data = lg
              .map<Item>(
                (item) => Item(
                  expandedValue: item.tips,
                  headerValue: item.name,
                  isExpanded: false,
                ),
              )
              .toList();

          return LGListView(data: data);
        }
      },
    );
  }
}

class LGListView extends StatefulWidget {
  final List<Item> data;

  const LGListView({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<LGListView> createState() => _LGListViewState();
}

class _LGListViewState extends State<LGListView> {
  late List<Item> data;
  @override
  void initState() {
    super.initState();
    data = widget.data; // Initialize data from the parent widget
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
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
          children: data.map<ExpansionPanel>((Item item) {
            return ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: Text(
                    item.headerValue,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
              body: ListTile(
                title: Text(item.expandedValue),
              ),
              isExpanded: item.isExpanded,
              canTapOnHeader: true,
            );
          }).toList(),
        ),
      ),
    );
  }
}
