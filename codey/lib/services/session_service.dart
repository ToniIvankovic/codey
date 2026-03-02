import 'package:codey/services/auth_service.dart';
import 'package:codey/services/user_service.dart';
import 'package:rxdart/rxdart.dart';

abstract class SessionService {
  Stream<void> get loginStream;
  Stream<void> get logoutStream;
  Future<void> logout();
  Future<void> login({
    required String username,
    required String password,
  });
}

class SessionService1 implements SessionService {
  final AuthService _authService;
  final UserService _userService;

  final PublishSubject<void> _loginSubject = PublishSubject<void>();
  final PublishSubject<void> _logoutSubject = PublishSubject<void>();

  SessionService1(this._authService, this._userService);

  @override
  Stream<void> get loginStream => _loginSubject.stream;

  @override
  Stream<void> get logoutStream => _logoutSubject.stream;

  @override
  Future<void> logout() async {
    await _authService.logout();
    _userService.logout();
    _logoutSubject.add(null);
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
    _loginSubject.add(null);
  }
}
