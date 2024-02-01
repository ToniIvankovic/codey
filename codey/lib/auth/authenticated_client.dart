import 'package:codey/models/exceptions/unauthorized_exception.dart';
import 'package:codey/services/auth_service.dart';
import 'package:http/http.dart' as http;

class AuthenticatedClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  final AuthService _authService; // Add this line

  AuthenticatedClient(this._authService); // Add this constructor

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await _authService.token;
    if (token == null) {
      throw UnauthenticatedException('No token or expired');
    }

    request.headers['Authorization'] = 'Bearer $token';
    return _inner.send(request);
  }
}
