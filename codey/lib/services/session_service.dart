import 'package:codey/services/auth_service.dart';
import 'package:codey/services/user_service.dart';

abstract class SessionService {
  Future<void> logout();
  Future<void> login({
    required String username,
    required String password,
  });
}

class SessionService1 implements SessionService {
  final AuthService _authService;
  final UserService _userService;

  SessionService1(this._authService, this._userService);

  @override
  Future<void> logout() async {
    await _authService.logout();
    _userService.logout();
  }

  @override
  Future<void> login({
    required String username,
    required String password,
  }) async {
    await _authService.login(
      username: username,
      password: password,
    );
    await _userService.initializeUser();
  }
}
