import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/login_credentials.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/storage_repository.dart';
import '../services/influx_validation_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final StorageRepository storageRepository;

  const AuthRepositoryImpl(this.storageRepository);

  @override
  Future<User?> login(LoginCredentials credentials) async {
    try {
      // Validar el token contra InfluxDB
      final organization = dotenv.env['INFLUXDB_ORG'] ?? 'microgrid';
      final isValidToken = await InfluxValidationService.validateToken(
        credentials.influxdbToken,
        organization,
      );

      if (!isValidToken) {
        return null;
      }

      // Obtener información adicional de InfluxDB
      final buckets = await InfluxValidationService.getBuckets(
        credentials.influxdbToken,
        organization,
      );

      final defaultBucket = buckets.isNotEmpty
          ? buckets.first
          : (dotenv.env['INFLUXDB_BUCKET'] ?? 'telemetry');

      // Crear usuario
      final user = User(
        deviceId: credentials.deviceId,
        organization: organization,
        bucket: defaultBucket,
        loginTime: DateTime.now(),
        isTokenValid: true,
      );

      // Guardar datos
      await storageRepository.saveUserData(user);
      await storageRepository.saveSecureToken(credentials.influxdbToken);

      return user;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final user = await storageRepository.getUserData();
      final token = await storageRepository.getSecureToken();

      if (user == null || token == null) {
        return null;
      }

      // Verificar si el token sigue siendo valido
      final isValid = await validateInfluxToken(token, user.organization);

      return user.copyWith(isTokenValid: isValid);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final user = await getCurrentUser();
      return user != null && user.isTokenValid;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await storageRepository.clearAllData();
    } catch (e) {
      throw Exception('Error al cerrar sesion: $e');
    }
  }

  @override
  Future<bool> validateInfluxToken(String token, String organization) async {
    return await InfluxValidationService.validateToken(token, organization);
  }
}
