import 'package:flutter/material.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

enum AuthStatus {
  initial,
  unauthenticated,
  authenticating,
  authenticated,
  error,
}

class AuthController extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LogoutUseCase logoutUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;

  AuthStatus _status = AuthStatus.initial;
  User? _currentUser;
  String? _errorMessage;

  AuthController({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.getCurrentUserUseCase,
    required this.logoutUseCase,
    required this.deleteAccountUseCase,
  });

  AuthStatus get status => _status;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticating => _status == AuthStatus.authenticating;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _currentUser != null;

  /// Check whether a persistent session exists on startup
  Future<void> checkAuthSession() async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      final user = await getCurrentUserUseCase();
      if (user != null) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
      } else {
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
    } finally {
      notifyListeners();
    }
  }

  /// Perform user login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await loginUseCase(email: email, password: password);
      _currentUser = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on Failure catch (f) {
      _errorMessage = f.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Perform user registration
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required UserRole role,
    String? teacherId,
    String? studentId,
    String? relationship,
    List<String>? teachingLevels,
    List<String>? teachingYears,
    List<String>? teachingSubjects,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await registerUseCase(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        role: role,
        teacherId: teacherId,
        studentId: studentId,
        relationship: relationship,
        teachingLevels: teachingLevels,
        teachingYears: teachingYears,
        teachingSubjects: teachingSubjects,
      );

      _currentUser = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on Failure catch (f) {
      _errorMessage = f.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Log out user
  Future<void> logout() async {
    try {
      await logoutUseCase();
    } finally {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Permanently delete account (Apple Guideline 5.1.1(v) compliance)
  Future<bool> deleteAccount() async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      await deleteAccountUseCase();
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on Failure catch (f) {
      _errorMessage = f.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Account deletion failed: $e';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }
}
