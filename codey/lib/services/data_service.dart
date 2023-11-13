import 'package:http/http.dart' as http;
import '/models/exercises_response.dart';
import 'dart:convert';

abstract class DataService {
  const DataService();
  void doSomething();
}

class DataServiceV1 extends DataService {
  DataServiceV1() {
    fetchData();
  }

  Future<void> fetchData() async {
    const String apiUrl = 'http://localhost:3000/api/v1/data/exercises';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON.
      final ExercisesResponse exercisesResponse =
          ExercisesResponse.fromJson({"exercises": jsonDecode(response.body)});
      print('Exercises: ${exercisesResponse.exercises}');
    } else {
      // If the server returns an unsuccessful response code, throw an exception.
      throw Exception('Failed to load data');
    }
  }

  @override
  void doSomething() {
    print('do something v1');
  }
}
