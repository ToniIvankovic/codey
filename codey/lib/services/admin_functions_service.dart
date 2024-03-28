import 'dart:convert';

import 'package:codey/models/exceptions/authentication_exception.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

abstract class AdminFunctionsService {
  Future<void> registerCreator(String username, String password);
}

class AdminFunctionsServiceImpl extends AdminFunctionsService {
  AdminFunctionsServiceImpl(this._authenticatedClient);
  final http.Client _authenticatedClient;
  
  @override
  Future<void> registerCreator(String username, String password) async {
    final response = await _authenticatedClient.post(
      Uri.parse('${dotenv.env["API_BASE"]}/user/register/creator'),
      body: json.encode({'email': username, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      var errorMessage = json.decode(response.body);
      errorMessage = errorMessage['message']
          .toString()
          .substring(1, errorMessage['message'].toString().length - 1)
          .split(", ")
          .join("\n");
      throw AuthenticationException(errorMessage);
    }
  }
}