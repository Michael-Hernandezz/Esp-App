import '../entities/user.dart';
import '../entities/login_credentials.dart';

abstract class AuthRepository {
  /// Realiza login con las credenciales proporcionadas
  Future<User?> login(LoginCredentials credentials);

  /// Obtiene el usuario actual si está autenticado
  Future<User?> getCurrentUser();

  /// Verifica si hay una sesion activa
  Future<bool> isLoggedIn();

  /// Cierra la sesion actual
  Future<void> logout();

  /// Verifica si el token de InfluxDB es valido
  Future<bool> validateInfluxToken(String token, String organization);
}
