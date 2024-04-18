import 'dart:convert';

import 'package:codey/models/exceptions/authentication_exception.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

abstract class AdminFunctionsService {
  Future<void> registerCreator({
    required String email,
    required String password,
  });
  Future<void> registerTeacher({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String school,
  });
}

class AdminFunctionsServiceImpl extends AdminFunctionsService {
  AdminFunctionsServiceImpl(this._authenticatedClient);
  final http.Client _authenticatedClient;

  @override
  Future<void> registerCreator({
    required String email,
    required String password,
  }) async {
    final response = await _authenticatedClient.post(
      Uri.parse('${dotenv.env["API_BASE"]}/user/register/creator'),
      body: json.encode({'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      var errorMessage = json.decode(response.body);
      throw AuthenticationException(_parseError(errorMessage));
    }
  }

  @override
  Future<void> registerTeacher({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String school,
  }) async {
    final response = await _authenticatedClient.post(
      Uri.parse('${dotenv.env["API_BASE"]}/user/register/teacher'),
      body: json.encode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'school': school,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      switch (response.statusCode) {
        case 401:
        case 403:
        case 404:
          throw AuthenticationException(response.reasonPhrase.toString());
        default:
          var errorMessage = json.decode(response.body);
          throw AuthenticationException(_parseError(errorMessage));
      }
    }
  }

  String _parseError(errorMessage) {
    return errorMessage['message']
        .toString()
        .substring(1, errorMessage['message'].toString().length - 1)
        .split(", ")
        .join("\n");
  }
}
