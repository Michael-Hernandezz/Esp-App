import '../entities/user.dart';

abstract class StorageRepository {
  /// Guarda datos no sensibles del usuario en SharedPreferences
  Future<void> saveUserData(User user);

  /// Obtiene datos no sensibles del usuario
  Future<User?> getUserData();

  /// Guarda el token de InfluxDB de forma segura
  Future<void> saveSecureToken(String token);

  /// Obtiene el token de InfluxDB de forma segura
  Future<String?> getSecureToken();

  /// Elimina todos los datos almacenados
  Future<void> clearAllData();

  /// Verifica si hay datos de usuario guardados
  Future<bool> hasUserData();
}
