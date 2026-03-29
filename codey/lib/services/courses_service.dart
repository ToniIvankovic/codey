import 'package:codey/models/entities/course.dart';
import 'package:codey/repositories/courses_repository.dart';

abstract class CoursesService {
  Future<List<Course>> getAllCourses();
}

// Intentionally thin — courses are public read-only data with no business logic.
// The service layer is kept for consistency with the rest of the app's architecture.
class CoursesServiceV1 implements CoursesService {
  final CoursesRepository _repo;

  CoursesServiceV1(this._repo);

  @override
  Future<List<Course>> getAllCourses() => _repo.getAllCourses();
}
