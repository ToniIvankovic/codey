
import 'package:codey/repositories/lesson_groups_repository.dart';

abstract class DataService {
  const DataService();
  void doSomething();
}

class DataServiceV1 implements DataService {
  DataServiceV1() {
    var lgr = LessonGroupsRepository();
    var lg = lgr.fetchLessonGroups();
    print(lg);
  }

  @override
  void doSomething() {
    print('do something v1');
  }
}
