import '../entities/user.dart';
import '../entities/login_credentials.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository authRepository;

  const LoginUseCase(this.authRepository);

  Future<LoginResult> execute(LoginCredentials credentials) async {
    try {
      // Validar que los campos no estén vacíos
      if (credentials.deviceId.trim().isEmpty) {
        return LoginResult.failure('El Device ID no puede estar vacío');
      }

      if (credentials.influxdbToken.trim().isEmpty) {
        return LoginResult.failure('El token de InfluxDB no puede estar vacío');
      }

      // Intentar hacer login
      final user = await authRepository.login(credentials);

      if (user != null) {
        return LoginResult.success(user);
      } else {
        return LoginResult.failure('Credenciales inválidas');
      }
    } catch (e) {
      return LoginResult.failure('Error durante el login: $e');
    }
  }
}

class LoginResult {
  final bool isSuccess;
  final User? user;
  final String? errorMessage;

  const LoginResult._({required this.isSuccess, this.user, this.errorMessage});

  factory LoginResult.success(User user) {
    return LoginResult._(isSuccess: true, user: user);
  }

  factory LoginResult.failure(String errorMessage) {
    return LoginResult._(isSuccess: false, errorMessage: errorMessage);
  }
}
