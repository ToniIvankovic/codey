import 'package:codey/services/auth_service.dart';
import 'package:codey/services/user_service.dart';

class SessionService {
  final AuthService _authService;
  final UserService _userService;

  SessionService(this._authService, this._userService);

  Future<void> logout() async {
    await _authService.logout();
    _userService.logout();
  }

  Future<void> login(String username, String password) async {
    await _authService.login(username, password);
    await _userService.initializeUser();
  }
}