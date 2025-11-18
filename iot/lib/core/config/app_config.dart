/// Configuración de la aplicación ESP-APP Flutter
/// Permite cambiar fácilmente entre desarrollo local y servidor en la nube
class AppConfig {
  // Configuración para el servidor en la nube (PRODUCCIÓN)
  static const bool useCloudServer = true;

  // URLs del servidor en la nube
  static const String cloudApiUrl = 'http://104.131.178.99:8000';
  static const String cloudInfluxUrl = 'http://104.131.178.99:8086';

  // URLs del servidor local (DESARROLLO)
  static const String localApiUrl = 'http://10.0.2.2:8000';
  static const String localInfluxUrl = 'http://10.0.2.2:8086';

  // Configuración de InfluxDB
  static const String influxToken =
      'm9dZ53tgCda7obiBCJn4xFVloD8q9zbqckGPvMzlPxJ3Jwb2ur6gGp-sgWD-KjHH5tvJIqgCSvpuVKeOHj66rw==';
  static const String influxOrg = 'microgrid';
  static const String influxBucket = 'telemetry';

  // Device ID por defecto
  static const String defaultDeviceId = 'dev-001';

  // URLs activas (basadas en la configuración)
  static String get apiUrl => useCloudServer ? cloudApiUrl : localApiUrl;
  static String get influxUrl =>
      useCloudServer ? cloudInfluxUrl : localInfluxUrl;

  // Configuración de debug
  static const bool enableDebugLogs = true;
  static const Duration refreshInterval = Duration(seconds: 5);

  // Configuración de MQTT (para referencia)
  static const String mqttBroker = '104.131.178.99';
  static const int mqttPort = 1883;
  static const String mqttUsername = 'admin';
  static const String mqttPassword = 'admin12345';
}

/// Utilidades para logging
class AppLogger {
  static void log(String message) {
    if (AppConfig.enableDebugLogs) {
      print('[ESP-APP] $message');
    }
  }

  static void error(String message, [dynamic error]) {
    print('[ESP-APP ERROR] $message');
    if (error != null) {
      print('[ESP-APP ERROR] Details: $error');
    }
  }
}
