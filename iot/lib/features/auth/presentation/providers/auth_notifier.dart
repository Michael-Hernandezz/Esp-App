import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/login_credentials.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({required this.status, this.user, this.errorMessage});

  factory AuthState.initial() {
    return const AuthState(status: AuthStatus.initial);
  }

  factory AuthState.loading() {
    return const AuthState(status: AuthStatus.loading);
  }

  factory AuthState.authenticated(User user) {
    return AuthState(status: AuthStatus.authenticated, user: user);
  }

  factory AuthState.unauthenticated() {
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  factory AuthState.error(String message) {
    return AuthState(status: AuthStatus.error, errorMessage: message);
  }

  AuthState copyWith({AuthStatus? status, User? user, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends ValueNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthNotifier(
    this._loginUseCase,
    this._logoutUseCase,
    this._getCurrentUserUseCase,
  ) : super(AuthState.initial());

  Future<void> checkAuthStatus() async {
    value = AuthState.loading();

    try {
      final user = await _getCurrentUserUseCase.execute();

      if (user != null && user.isTokenValid) {
        value = AuthState.authenticated(user);
      } else {
        value = AuthState.unauthenticated();
      }
    } catch (e) {
      value = AuthState.error('Error verificando autenticacion: $e');
    }
  }

  Future<void> login(String deviceId, String influxdbToken) async {
    value = AuthState.loading();

    try {
      final credentials = LoginCredentials(
        deviceId: deviceId,
        influxdbToken: influxdbToken,
      );

      final result = await _loginUseCase.execute(credentials);

      if (result.isSuccess && result.user != null) {
        value = AuthState.authenticated(result.user!);
      } else {
        value = AuthState.error(result.errorMessage ?? 'Error desconocido');
      }
    } catch (e) {
      value = AuthState.error('Error durante el login: $e');
    }
  }

  Future<void> logout() async {
    value = AuthState.loading();

    try {
      await _logoutUseCase.execute();
      value = AuthState.unauthenticated();
    } catch (e) {
      value = AuthState.error('Error al cerrar sesion: $e');
    }
  }

  void clearError() {
    if (value.status == AuthStatus.error) {
      value = AuthState.unauthenticated();
    }
  }
}
